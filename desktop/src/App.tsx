import {
  AppBar,
  Drawer,
  IconButton,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Toolbar
} from '@material-ui/core';
import React, { useState } from 'react';
import { HashRouter as Router, Switch, Route, Link } from 'react-router-dom';
import { Menu as MenuIcon, Person, Note, Fastfood } from '@material-ui/icons';
import { View } from './View';

const tableNames = [
  'discounts',
  'price_multipliers',
  'product_availability',
  "products_per_order",
  "orders_per_client",
  "awaiting_acceptation",
  "orders_per_client",
  "price_table_daily",
  "todays_products",
  "discount_eligibility",
  "passive_discounts",
  'order_product',
  'reservation',
  'seat_limit'
];

const tabs = [
  {
    name: 'Orders',
    component: () => <View table="order" />,
    icon: Note
  },
  {
    name: 'Products',
    component: () => <View table="product" />,
    icon: Fastfood
  },
  {
    name: 'Client - People',
    component: () => <View table="client_person" />,
    icon: Person
  },
  {
    name: 'Client - Companies',
    component: () => <View table="client_company" />,
    icon: Person
  },
  ...tableNames.map(table => ({
    name: table
      .replaceAll('_', ' ')
      .replace(/(\b[a-z](?!\s))/g, x => x.toUpperCase()),
    component: () => <View table={table} />,
    icon: Fastfood
  }))
];

export default function App() {
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const toggleDrawer = () => setIsDrawerOpen(prev => !prev);
  const [tab, setTab] = useState(0);

  const TabComponent = tabs[tab].component;

  return (
    <Router>
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
      <div style={{ height: '64px' }} />
      <Drawer
        PaperProps={{ style: { minWidth: 'min(85vw, 300px)' } }}
        anchor="left"
        open={isDrawerOpen}
        onClose={() => setIsDrawerOpen(false)}
      >
        <List>
          {tabs.map(({ icon: Icon, name }, i) => {
            return (
              <ListItem button key={name} onClick={() => setTab(i)}>
                <ListItemIcon>
                  <Icon />
                </ListItemIcon>
                <ListItemText primary={name} />
              </ListItem>
            );
          })}
        </List>
      </Drawer>

      <TabComponent />
    </Router>
  );
}
