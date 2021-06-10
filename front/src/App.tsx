import React, { useEffect, useState } from "react";
import {
  AppBar,
  Button,
  CssBaseline,
  Drawer,
  IconButton,
  ListItemText,
  ListItem,
  Toolbar,
  Typography,
  List,
  ListItemIcon
} from "@material-ui/core";
import { api, useProducts } from "./api";
import { Menu as MenuIcon, Person, Note, Fastfood } from "@material-ui/icons";

const icons = {
  Orders: Note,
  Products: Fastfood,
  Clients: Person
};

function App() {
  const { data, isLoading } = useProducts();
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const toggleDrawer = () => setIsDrawerOpen(prev => !prev);

  return (
    <>
      <CssBaseline />
      <AppBar position="fixed">
        <Toolbar>
          <IconButton
            edge="start"
            color="inherit"
            aria-label="menu"
            onClick={toggleDrawer}
          >
            <MenuIcon />
          </IconButton>
        </Toolbar>
      </AppBar>
      <Drawer
        PaperProps={{ style: { minWidth: "min(85vw, 300px)" } }}
        anchor="left"
        open={isDrawerOpen}
        onClose={() => setIsDrawerOpen(false)}
      >
        <List>
          {["Orders", "Clients", "Products"].map((text, index) => {
            const Icon = icons[text];
            return (
              <ListItem button key={text}>
                <ListItemIcon>
                  <Icon />
                </ListItemIcon>
                <ListItemText primary={text} />
              </ListItem>
            );
          })}
        </List>
      </Drawer>
      <div>Hello</div>
      {data && (data as any).map(product => <div>{product.id}</div>)}
    </>
  );
}

export default App;
