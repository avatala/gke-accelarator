import React from "react";
import { Link } from "react-router-dom";

export function HealthPage() {
  return (
    <div>
        <ul>
          <li>
            <Link to="/">To HomePage</Link>
          </li>
        </ul>
      <h1>Health Page!</h1>
    </div>
  );
}