import React from "react";
import ReactDOM from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import "./index.css";
import PageOne from "./routes/page_one";
import PageTwo from "./routes/page_two";
import Root from "./routes/root";

const router = createBrowserRouter([
  {
    path: import.meta.env.BASE_URL,
    element: <Root />,
    children: [
      {
        path: `${import.meta.env.BASE_URL}/page-one`,
        element: <PageOne />,
      },
      {
        path: `${import.meta.env.BASE_URL}/page-two`,
        element: <PageTwo />,
      },
    ],
  },
]);

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
