export function injectScript(url: string) {
  return new Promise<void>((resolve) => {
    const element = document.createElement('script');
    element.src = url;
    element.type = 'text/javascript';
    element.async = true;
    element.onload = () => {
      resolve();
    };
    document.head.appendChild(element);
  });
}

export async function loadFederatedModule(remote: string, module: string) {
  await __webpack_init_sharing__('default');
  const container = window[remote];
  await container.init(__webpack_share_scopes__.default);
  const factory = await window[remote].get(module);
  const Module = factory();
  return Module;
}
