#!/bin/bash
set -e

# Colors for the banner
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print Welcome Message
echo -e "${BLUE}==================================================================${NC}"
echo -e "${GREEN}   🚀 edugonmor-cli Environment Ready${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo -e "   - Type ${GREEN}'edugonmor --help'${NC} to see available commands."
echo -e "   - Shortcut: ${GREEN}connect${NC} is available to start a session."
echo -e "   - Type ${GREEN}'exit'${NC} to leave the container."
echo -e "${BLUE}==================================================================${NC}"
echo ""

# Define aliases for better UX
echo "alias list='edugonmor list'" >> ~/.bashrc
echo "alias create='edugonmor create'" >> ~/.bashrc
echo "alias update='edugonmor update'" >> ~/.bashrc
echo "alias connect='edugonmor connect'" >> ~/.bashrc
echo "alias disconnect='edugonmor disconnect'" >> ~/.bashrc

# Execute the passed command
if [ "$1" = "/bin/bash" ] || [ "$1" = "tail" ]; then
    exec "$@"
else
    # Execute the passed command but keep container alive
    echo -e "${GREEN}Running command: $*${NC}"
    echo ""
    
    set +e # Allow command to fail without closing container
    "$@"
    EXIT_CODE=$?
    set -e
    
    echo ""
    echo -e "${BLUE}==================================================================${NC}"
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}   ✅ Command finished successfully.${NC}"
    elif [ $EXIT_CODE -eq 127 ]; then
        echo -e "${GREEN}   ⚠️ Command not found. Please check your spelling.${NC}"
    else
        echo -e "${GREEN}   ⚠️ Command finished with error (code $EXIT_CODE).${NC}"
    fi
    echo -e "${GREEN}   Starting interactive shell...${NC}"
    echo -e "${BLUE}==================================================================${NC}"
    
    exec /bin/bash
fi
