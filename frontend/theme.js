(() => {
  const key = "portfolio-theme";
  const system = window.matchMedia("(prefers-color-scheme: dark)");
  const isTheme = (value) => value === "dark" || value === "light";
  const readPreference = () => {
    try {
      const cookie = document.cookie.split("; ").find((item) => item.startsWith(`${key}=`));
      const value = cookie ? cookie.split("=")[1] : localStorage.getItem(key);
      return isTheme(value) ? value : null;
    } catch { return null; }
  };
  let preference = readPreference();
  const apply = (theme) => {
    document.documentElement.dataset.theme = theme;
    document.querySelectorAll("[data-theme-toggle]").forEach((button) => {
      const dark = theme === "dark";
      button.textContent = dark ? "Light mode" : "Dark mode";
      button.setAttribute("aria-pressed", String(dark));
      button.title = `Switch to ${dark ? "light" : "dark"} mode`;
    });
  };
  const current = () => preference || (system.matches ? "dark" : "light");
  apply(current());
  document.addEventListener("DOMContentLoaded", () => {
    apply(current());
    document.querySelectorAll("[data-theme-toggle]").forEach((button) => {
      button.hidden = false;
      button.addEventListener("click", () => {
        preference = document.documentElement.dataset.theme === "dark" ? "light" : "dark";
        apply(preference);
        try { localStorage.setItem(key, preference); } catch { /* Storage can be disabled. */ }
        try {
          const hostname = location.hostname;
          const domain = hostname === "harry-sivasambu.com" || hostname.endsWith(".harry-sivasambu.com")
            ? "; Domain=harry-sivasambu.com" : "";
          document.cookie = `${key}=${preference}; Path=/; Max-Age=31536000; SameSite=Lax${domain}${location.protocol === "https:" ? "; Secure" : ""}`;
        } catch { /* The toggle still works without persistence. */ }
      });
    });
  });
  system.addEventListener("change", () => { if (!preference) apply(current()); });
  window.addEventListener("storage", (event) => {
    if (event.key === key) { preference = isTheme(event.newValue) ? event.newValue : null; apply(current()); }
  });
})();
