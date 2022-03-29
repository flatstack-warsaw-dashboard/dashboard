import { Suspense, createElement } from 'react';
import styled from 'styled-components';
import config from './config';
import { injectScript, loadFederatedModule } from './federation';

type Props = typeof config[number];

const Wrapper = styled.section`
  width: 100%;
  height: 35em;
  box-shadow: 0 0.5em 1em 0.2em rgba(0, 0, 0, 0.5);
`;

const Header = styled.header`
  padding: 1em;
  font-weight: bold;
  border-bottom: 1px solid #bbbbbb;
`;

const loadedWidgets: { [k in typeof config[number]['id']]?: true } = {};

const LazyWidget = (widgetConfig: Props) => {
  const isWidgetLoaded = loadedWidgets[widgetConfig.id];

  if (isWidgetLoaded) {
    return createElement(widgetConfig.customElement);
  }

  throw (async () => {
    await injectScript(widgetConfig.remoteUrl);
    await loadFederatedModule(
      widgetConfig.remoteName,
      widgetConfig.exposedName,
    );
    loadedWidgets[widgetConfig.id] = true;
  })();
};

const LoadingFallback = styled.div`
  height: 100%;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
`;

const Widget = (widgetConfig: Props) => (
  <Wrapper>
    <Header>{widgetConfig.name}</Header>
    <Suspense fallback={<LoadingFallback>Loading...</LoadingFallback>}>
      <LazyWidget {...widgetConfig} />
    </Suspense>
  </Wrapper>
);

export default Widget;
