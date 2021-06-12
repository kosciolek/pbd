/** @type {import('@docusaurus/types').DocusaurusConfig} */
module.exports = {
  title: "AGH - PBD - 2021",
  tagline: "Juliusz Kościołek - Kamil Medoń - Grzegorz Nessler",
  url: "https://your-docusaurus-test-site.com",
  baseUrl: "/",
  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",
  favicon: "img/favicon.ico",
  organizationName: "kosciolek",
  projectName: "pbd",
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
          href: "https://github.com/kosciolek/pbd/",
          label: "GitHub",
          position: "right"
        }
      ]
    },
    footer: {
      style: "dark",
      links: [],
      copyright: `Copyright © ${new Date().getFullYear()} Juliusz Kościołek, Kamil Medoń, Grzegorz Nessler`
    }
  },
  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: {
          sidebarPath: require.resolve("./sidebars.js"),
          // Please change this to your repo.
          editUrl: "https://github.com/kosciolek/pbd/tree/master/docs"
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css")
        }
      }
    ]
  ]
};
