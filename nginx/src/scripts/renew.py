import ovh
import os
import requests
import datetime
from dotenv import load_dotenv
import argparse
from typing import Optional


def get_public_ip(override: Optional[str] = None):
    if override:
        return override
    try:
        response = requests.get('https://api.ipify.org', timeout=10)
        return response.text if response.status_code == 200 else None
    except requests.RequestException as e:
        print(f"Error al obtener la dirección IP pública: {e}")
        return None


def str_to_bool(val: str) -> bool:
    return str(val).strip().lower() in {"1", "true", "yes", "on"}


# Imprime la hora de inicio del script
print(f"Inicio del script: {datetime.datetime.now()}")

# Carga .env si existe (también en runtime dentro del contenedor).
# Usamos override=True para permitir que cambios en el archivo se apliquen
# incluso si ya existen variables de entorno en el proceso.
_base = os.path.dirname(os.path.abspath(__file__))
_dotenv_default = os.path.join(_base, '../../.env')  # /app/.env dentro del contenedor
_dotenv_path = os.getenv("DOTENV_PATH", _dotenv_default)
load_dotenv(dotenv_path=_dotenv_path, override=True)

# CLI args
parser = argparse.ArgumentParser(description="Actualiza DynHost de OVH para una lista de subdominios")
parser.add_argument("--dry-run", action="store_true", help="No aplica cambios, solo muestra lo que haría")
parser.add_argument("--offline", action="store_true", help="No realiza llamadas a la API de OVH")
parser.add_argument("--ip", type=str, help="IP a usar (omite consulta pública)")
args = parser.parse_args()

# Dry-run por env o flag
env_dry_run = str_to_bool(os.getenv("RENEW_DRY_RUN", "false"))
DRY_RUN = args.dry_run or env_dry_run
if DRY_RUN:
    print("[DRY-RUN] No se aplicarán cambios en OVH.")

# Offline por env o flag
env_offline = str_to_bool(os.getenv("RENEW_OFFLINE", "false"))
OFFLINE = args.offline or env_offline
if OFFLINE:
    print("[OFFLINE] No se harán llamadas a la API de OVH.")

# Dominio e IP
domain = os.getenv('OVH_NAME') or 'example.com'
ip = get_public_ip(args.ip)

# Cargar subdominios desde .env
subdomains_env = os.getenv('OVH_SUBDOMAINS', '')
subdomains = [s.strip() for s in subdomains_env.split(',') if s.strip()]

if not ip:
    print("No se pudo obtener la dirección IP pública.")
else:
    if not subdomains:
        print("No hay subdominios definidos en OVH_SUBDOMAINS. Nada que hacer.")

    if OFFLINE:
        # Modo offline: no instanciar cliente ni llamar a OVH
        for subdomain in subdomains:
            print(f"[OFFLINE] Verificaría/actualizaría {subdomain}.{domain} a {ip}")
        print(f"[OFFLINE] Refrescaría la zona DNS para {domain}")
    else:
        # Configura el cliente de la API de OVH
        client = ovh.Client(
            endpoint=os.getenv('OVH_ENDPOINT'),
            application_key=os.getenv('OVH_APPLICATION_KEY'),
            application_secret=os.getenv('OVH_APPLICATION_SECRET'),
            consumer_key=os.getenv('OVH_CONSUMER_KEY'),
        )

        # Actualizar el dominio raíz (registro A sin subdominio)
        try:
            # Obtener registros A del dominio raíz
            root_records = client.get(f'/domain/zone/{domain}/record', fieldType='A', subDomain='')
            
            if root_records:
                for record_id in root_records:
                    record = client.get(f'/domain/zone/{domain}/record/{record_id}')
                    if record.get('target') != ip:
                        if DRY_RUN:
                            print(f"[DRY-RUN] Actualizaría IP del dominio raíz {domain} de {record.get('target')} a {ip}")
                        else:
                            client.put(f'/domain/zone/{domain}/record/{record_id}', target=ip)
                            print(f"IP actualizada para el dominio raíz {domain} a {ip}")
                    else:
                        print(f"La IP para el dominio raíz {domain} ya está actualizada.")
            else:
                # Si no existe, crear registro A para el dominio raíz
                if DRY_RUN:
                    print(f"[DRY-RUN] Crearía registro A para el dominio raíz {domain} con IP {ip}")
                else:
                    client.post(f'/domain/zone/{domain}/record', fieldType='A', subDomain='', target=ip)
                    print(f"Registro A creado para el dominio raíz {domain} con IP {ip}")
        except ovh.exceptions.APIError as e:
            print(f"Error actualizando dominio raíz {domain}: {e}")

        for subdomain in subdomains:
            try:
                # Obtén los registros DynHost existentes para el subdominio
                records = client.get(f'/domain/zone/{domain}/dynHost/record', subDomain=subdomain)

                if records:
                    # Si hay registros, actualiza la IP si es necesario
                    for record_id in records:
                        record = client.get(f'/domain/zone/{domain}/dynHost/record/{record_id}')
                        if record.get('ip') != ip:
                            if DRY_RUN:
                                print(f"[DRY-RUN] Actualizaría IP para {subdomain}.{domain} de {record.get('ip')} a {ip}")
                            else:
                                client.put(f'/domain/zone/{domain}/dynHost/record/{record_id}', ip=ip)
                                print(f"IP actualizada para {subdomain}.{domain} a {ip}")
                        else:
                            print(f"La IP para {subdomain}.{domain} ya está actualizada.")
                else:
                    # Si no hay registros, crea uno nuevo
                    if DRY_RUN:
                        print(f"[DRY-RUN] Crearía DynHost para {subdomain}.{domain} con IP {ip}")
                    else:
                        client.post(f'/domain/zone/{domain}/dynHost/record', subDomain=subdomain, ip=ip, login=subdomain)
                        print(f"DynHost creado para {subdomain}.{domain} con IP {ip}")

            except ovh.exceptions.ResourceNotFoundError:
                # Si no existe el registro, créalo
                if DRY_RUN:
                    print(f"[DRY-RUN] Crearía DynHost (no encontrado) para {subdomain}.{domain} con IP {ip}")
                else:
                    client.post(f'/domain/zone/{domain}/dynHost/record', subDomain=subdomain, ip=ip, login=subdomain)
                    print(f"DynHost creado para {subdomain}.{domain} con IP {ip}")
            except ovh.exceptions.APIError as e:
                print(f"Error con {subdomain}.{domain}: {e}")

            # Refresca la zona DNS después de actualizar o crear el registro
            try:
                if DRY_RUN:
                    print(f"[DRY-RUN] Refrescaría la zona DNS para {domain}")
                else:
                    client.post(f'/domain/zone/{domain}/refresh')
                    print(f"Zona DNS refrescada para {domain}")
            except ovh.exceptions.APIError as e:
                print(f"Error al refrescar la zona DNS para {domain}: {e}")

# Imprime la hora de finalización del script
print(f"Fin del script: {datetime.datetime.now()}")
