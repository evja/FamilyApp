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
    // New standardized button classes
    ".btn-primary": {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      borderRadius: theme("borderRadius.lg"),
      padding: `${theme("spacing.2")} ${theme("spacing.4")}`,
      fontWeight: "500",
      backgroundColor: "var(--primary-color)",
      color: theme("colors.white"),
      transition: "all 0.2s",
      "&:hover": {
        opacity: "0.9",
      },
    },
    ".btn-secondary": {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      borderRadius: theme("borderRadius.lg"),
      padding: `${theme("spacing.2")} ${theme("spacing.4")}`,
      fontWeight: "500",
      border: "1px solid var(--primary-color)",
      color: "var(--primary-color)",
      backgroundColor: "transparent",
      transition: "all 0.2s",
      "&:hover": {
        backgroundColor: theme("colors.gray.50"),
      },
    },
    ".btn-danger": {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      borderRadius: theme("borderRadius.lg"),
      padding: `${theme("spacing.2")} ${theme("spacing.4")}`,
      fontWeight: "500",
      backgroundColor: theme("colors.red.600"),
      color: theme("colors.white"),
      transition: "all 0.2s",
      "&:hover": {
        backgroundColor: theme("colors.red.700"),
      },
      "&:disabled": {
        opacity: "0.5",
        cursor: "not-allowed",
      },
    },
    ".btn-danger-text": {
      color: theme("colors.red.600"),
      fontSize: theme("fontSize.sm")[0],
      "&:hover": {
        color: theme("colors.red.800"),
        textDecoration: "underline",
      },
    },
  });
});
