export default [
  {
    id: 'helloWorldWidget',
    remoteUrl:
      'https://flatstack-warsaw-dashboard.github.io/hello-world-widget/remote.js',
    remoteName: 'helloWorldWidget',
    exposedName: '.',
    name: 'Hello',
    customElement: 'fwd-hello-world-widget',
    position: {
      x: 0,
      y: 0,
      width: 10,
      height: 10,
    },
  },
] as const;
