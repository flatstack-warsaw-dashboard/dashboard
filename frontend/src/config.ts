export default [
  {
    id: 'ptosWidget',
    remoteUrl:
      'https://ptos-widget.s3.eu-central-1.amazonaws.com/dist/remote.js',
    remoteName: 'ptosWidget',
    name: 'Personal days-off',
    exposedName: '.',
    customElement: 'fwd-ptos-widget',
  },
  {
    id: 'PublicRetroBoardWidgetAdamantium',
    remoteUrl:
      'https://objectstorage.eu-amsterdam-1.oraclecloud.com/n/ax4mayunfiab/b/Retro-app-bucket/o/dist/PublicRetroBoardWidget.js',
    remoteName: 'PublicRetroBoardWidget',
    name: 'Retro Board',
    exposedName: '.',
    customElement: 'fwd-retro-board-adamantium',
  },
  {
    id: 'helloWorldWidget',
    remoteUrl:
      'https://flatstack-warsaw-dashboard.github.io/hello-world-widget/remote.js',
    remoteName: 'helloWorldWidget',
    exposedName: '.',
    name: 'Hello!',
    customElement: 'fwd-hello-world-widget',
  },
  {
    id: 'FwdTweetWidget',
    remoteUrl: 'https://widget-dist-bucket.s3.amazonaws.com/remote.js',
    remoteName: 'FwdTweetWidget',
    name: 'Recent Messages',
    exposedName: '.',
    customElement: 'fwd-tweet-widget',
    position: {
      x: 0, y: 0, height: 320, width: 320,
    },
  },
  {
    id: 'BirthdaysWidget',
    remoteUrl: 'https://birthdays-widget.s3.eu-central-1.amazonaws.com/dist/remote.js',
    remoteName: 'birthdaysWidget',
    name: 'Upcoming birthdays',
    exposedName: '.',
    customElement: 'fwd-birthdays-widget',
  },
] as const;
