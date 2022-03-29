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
  padding: 1rem;
`;

const Header = styled.header`
  box-shadow: 0 0.5em 1em 0.2em rgba(0, 0, 0, 0.5);
  font-weight: bold;
  font-size: 1.2em;
`;

const App = () => (
  <>
    <GlobalStyle />
    <Header>
      <Container>Flatstack Warsaw Dashboard</Container>
    </Header>
    <Container>
      {config.map((widgetConfig) => (
        <Widget key={widgetConfig.id} {...widgetConfig} />
      ))}
    </Container>
  </>
);

export default App;
