import React from "react";
import { Link } from "react-router-dom";

export function HomePage() {
  return (
    <div>
      <ul>
          <li>
            <Link to="/health">To HealthPage</Link>
          </li>
        </ul>
      <h1>Home Page!</h1>
    </div>
  );
}