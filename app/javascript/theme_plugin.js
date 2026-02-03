const plugin = require("tailwindcss/plugin");

module.exports = plugin(function ({ addComponents, theme }) {
  addComponents({
    ".theme-header": {
      backgroundColor: theme("colors.slate.900"),
    },
    ".theme-text": {
      color: theme("colors.slate.900"),
    },
    ".theme-button": {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      borderRadius: theme("borderRadius.md"),
      padding: `${theme("spacing.2")} ${theme("spacing.4")}`,
      backgroundColor: theme("colors.slate.900"),
      color: theme("colors.white"),
    },
    ".theme-button-filled": {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      borderRadius: theme("borderRadius.md"),
      padding: `${theme("spacing.2")} ${theme("spacing.3")}`,
      backgroundColor: theme("colors.slate.900"),
      color: theme("colors.white"),
    },
    ".theme-button-outline": {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      borderRadius: theme("borderRadius.md"),
      padding: `${theme("spacing.2")} ${theme("spacing.3")}`,
      border: `1px solid ${theme("colors.white")}`,
      color: theme("colors.white"),
    },
  });
});
