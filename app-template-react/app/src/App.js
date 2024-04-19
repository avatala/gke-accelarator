import './App.css';
import {
  BrowserRouter as Router,
  Routes,
  Route
} from "react-router-dom";
import { HomePage } from './components/HomePage';
import { HealthPage } from './components/HealthPage';


function App() {
  return (
    <div>
      
      <Router>
        <Routes>
          <Route exact path="/" element={<HomePage/>} />
          <Route exact path="/health" element={<HealthPage/>} />
        </Routes>
      </Router>
    </div>
  );
}

export default App;
