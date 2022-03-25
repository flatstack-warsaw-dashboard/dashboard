import config from './config';

const root = document.getElementById('root');

async function init() {
  config.forEach(async (widgetConfig) => {
    await import(/* webpackIgnore: true */ widgetConfig.url);

    if (!root) {
      return;
    }

    const el = document.createElement(widgetConfig.customElement);
    root.appendChild(el);
  });
}

init();
