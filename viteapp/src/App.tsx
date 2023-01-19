import "./App.css";

function App() {
  return (
    <div className="App">
      <h1>You are viewing {import.meta.env.VITE_APP_ID}</h1>
      <ul>
        <li>
          <a href={`${import.meta.env.VITE_APPLICATION_ONE_ROOT_URL}/page-one`}>
            Application One - Page One
          </a>
          <li>
            <a href={`${import.meta.env.VITE_APPLICATION_ONE_ROOT_URL}/page-two`}>
              Application One - Page Two
            </a>
          </li>
          <li>
            <a href={`${import.meta.env.VITE_APPLICATION_TWO_ROOT_URL}/page-one`}>
              Application Two - Page One
            </a>
          </li>
          <li>
            <a href={`${import.meta.env.VITE_APPLICATION_TWO_ROOT_URL}/page-two`}>
              Application Two - Page Two
            </a>
          </li>
        </li>
      </ul>
    </div>
  );
}

export default App;
