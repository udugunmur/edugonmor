import { fn } from '@storybook/test';

export default {
    title: 'Example/Button',
    tags: ['autodocs'],
    render: ({ label, ...args }) => {
        const btn = document.createElement('button');
        btn.innerHTML = label;
        btn.type = 'button';
        btn.className = ['storybook-button', `storybook-button--${args.size || 'medium'}`].join(' ');
        btn.style.backgroundColor = args.backgroundColor;
        btn.addEventListener('click', args.onClick);
        return btn;
    },
    args: {
        onClick: fn(),
    },
};

export const Primary = {
    args: {
        primary: true,
        label: 'Button',
    },
};
