import { Outlet } from "react-router-dom";
import "../App.css";
import FlexLink from "../components/FlexLink";

function Root() {
  return (
    <div className="App">
      <h1>You are viewing:</h1>
      <h2>Application: {import.meta.env.VITE_APP_ID}</h2>
      <Outlet />
      <ul>
        <li>
          <FlexLink
            to={`${import.meta.env.VITE_APPLICATION_ONE_ROOT_URL}/page-one`}
          >
            Application One - Page One
          </FlexLink>
        </li>
        <li>
          <FlexLink
            to={`${import.meta.env.VITE_APPLICATION_ONE_ROOT_URL}/page-two`}
          >
            Application One - Page Two
          </FlexLink>
        </li>
        <li>
          <FlexLink
            to={`${import.meta.env.VITE_APPLICATION_TWO_ROOT_URL}/page-one`}
          >
            Application Two - Page One
          </FlexLink>
        </li>
        <li>
          <FlexLink
            to={`${import.meta.env.VITE_APPLICATION_TWO_ROOT_URL}/page-two`}
          >
            Application Two - Page Two
          </FlexLink>
        </li>
      </ul>
      <ul>
        {Object.entries(import.meta.env).map(([key, value]) => (
          <li key={key}>{`${key} -> ${value}`}</li>
        ))}
      </ul>
    </div>
  );
}

export default Root;
