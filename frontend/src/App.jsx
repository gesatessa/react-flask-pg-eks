import { useEffect, useState } from 'react';
import axios from 'axios';


//const API_URL = 'http://3.83.202.13:5000';
//const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';
//const API_URL = import.meta.env.VITE_API_URL; // docker-compose
const API_URL = '/api' // ingress

function App() {
  const [form, setForm] = useState({ name: '', series_name: '', rating: 0 });
  const [recent, setRecent] = useState([]);
  const [stats, setStats] = useState(null);
  const [seriesQuery, setSeriesQuery] = useState('');

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const submitRating = async () => {
    await axios.post(`${API_URL}/rate`, {
      ...form,
      rating: Number(form.rating),
    });
    setForm({ name: '', series_name: '', rating: 0 });
    fetchRecent();
  };

  const fetchRecent = async () => {
    const res = await axios.get(`${API_URL}/recent`);
    setRecent(res.data);
  };

  const fetchStats = async () => {
    const res = await axios.get(`${API_URL}/stats/${seriesQuery}`);
    setStats(res.data);
  };

  useEffect(() => {
    fetchRecent();
  }, []);

  return (
    <div style={{ padding: 20 }}>
      <h2>Submit Rating</h2>
      <input name="name" value={form.name} onChange={handleChange} placeholder="Your Name" />
      <input name="series_name" value={form.series_name} onChange={handleChange} placeholder="Series Name" />
      <input name="rating" type="number" min="0" max="5" value={form.rating} onChange={handleChange} />
      <button onClick={submitRating}>Submit</button>

      <h2>Last 5 Ratings:</h2>
      <ul>
        {recent.map((r, idx) => (
          <li key={idx}>{r.name} rated {r.series_name} → {r.rating}/5</li>
        ))}
      </ul>

      <h2>Get Series Stats</h2>
      <input value={seriesQuery} onChange={(e) => setSeriesQuery(e.target.value)} placeholder="Series Name" />
      <button onClick={fetchStats}>Fetch Stats</button>
      {stats && (
        <div>
          <p>Series: {stats.series_name}</p>
          <p>Ratings Count: {stats.count}</p>
          <p>Average: {stats.average}</p>
        </div>
      )}
    </div>
  );
}

export default App;
