import './main.css';
import { Elm } from './Main.elm';

const enableDarkMode = () => {
  const root = document.documentElement;

  root.style.setProperty('--text-color', '#ffffff');
  root.style.setProperty('--background', '#293c4b');
}

const disableDarkMode = () => {
  const root = document.documentElement;

  root.style.setProperty('--text-color', '#293c4b');
  root.style.setProperty('--background', 'white');
}

const isDarkMode = localStorage.getItem("dark_mode") === 'true';

if (isDarkMode) {
  enableDarkMode();
}

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: isDarkMode
});

app.ports.toggleDarkMode.subscribe((isDarkModeOn) => {
  const root = document.documentElement;
  localStorage.setItem("dark_mode", isDarkModeOn);

  if (isDarkModeOn) {
    enableDarkMode();
  } else {
    disableDarkMode();
  }
});
