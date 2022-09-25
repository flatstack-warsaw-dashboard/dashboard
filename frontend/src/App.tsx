import styled, { createGlobalStyle } from 'styled-components';
import config from './config';
import Widget from './Widget';

const GlobalStyle = createGlobalStyle`
  body {
    margin: 0;
    font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol";
    font-size: 1rem;
    -webkit-font-smoothing: antialiased;
  }

  * {
    box-sizing: border-box;
  }
`;

const Container = styled.div`
  display: flex;
  flex-wrap: wrap;
`;

const App = () => (
  <>
    <GlobalStyle />
    <Container>
      {config.map((widgetConfig) => (
        <Widget key={widgetConfig.id} {...widgetConfig} />
      ))}
    </Container>
  </>
);

export default App;
