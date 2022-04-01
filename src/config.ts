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
  {
    id: 'ptosWidget',
    remoteUrl:
      'https://ptos-widget.s3.eu-central-1.amazonaws.com/dist/remote.js',
    remoteName: 'ptosWidget',
    name: 'PTOs Widget',
    exposedName: '.',
    customElement: 'fwd-ptos-widget',
    position: {
      x: 15,
      y: 0,
      width: 320,
      height: 320,
    },
  },
] as const;
