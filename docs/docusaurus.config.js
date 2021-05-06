/** @type {import('@docusaurus/types').DocusaurusConfig} */
module.exports = {
  title: "AGH - PBD - 2021",
  tagline: "Juliusz Kościołek - Kamil Medoń - Grzegorz Nessler",
  url: "https://your-docusaurus-test-site.com",
  baseUrl: "/",
  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",
  favicon: "img/favicon.ico",
  organizationName: "jk-agh", // Usually your GitHub org/user name.
  projectName: "docusaurus", // Usually your repo name.
  themeConfig: {
    navbar: {
      title: "AGH PBD 2021",
      logo: {
        alt: "agh logo",
        src: "img/agh.webp"
      },
      items: [
        {
          type: "doc",
          docId: "intro",
          position: "left",
          label: "Docs"
        },
        {
          href: "https://github.com/jk-agh/pbd/",
          label: "GitHub",
          position: "right"
        }
      ]
    },
    footer: {
      style: "dark",
      links: [],
      copyright: `Copyright © ${new Date().getFullYear()} Juliusz Kościołek`
    }
  },
  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: {
          sidebarPath: require.resolve("./sidebars.js"),
          // Please change this to your repo.
          editUrl: "https://github.com/jk-agh/pbd/"
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css")
        }
      }
    ]
  ]
};
