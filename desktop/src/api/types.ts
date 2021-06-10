export interface Product {
  id: string;
  tax_percent: number;
  isSeafood: boolean;
  description: string | null;
}

export interface ProductAvailability {
  product_id: string;
  price: number;
  date: Date;
}

export interface Client {
  id: number;
}

export interface ClientPerson {
  id: number;
  first_name: string;
  second_name: string;
  phone_number: string;
}

export interface ClientCompany {
  id: number;
  name: string;
  phone_number: string;
  nip: string;
}

export interface ClientEmployee {
  id: number;
  company_id: number;
  first_name: string;
  second_name: string;
  phone_number: string | null;
}

export interface Const {
  z1: number;
  k1: number;
  r1: number;
  k2: number;
  r2: number;
  d1: number;

  min_orders_cheap_reservation: number;
  cheap_reservation_price: number;
  expensive_reservation_price: number;

  max_reservation_minutes: number;
}

export interface Discount {
  id: number;
  date_start: Date;
  client_person_id: number;
}

export interface Order {
  id: number;
  placed_at: Date;
  preferred_serve_time: Date;
  isTakeaway: boolean;
  order_owner_id: number | null;
  state: 'placed' | 'accepted' | 'rejected' | 'completed';
  date_placed: Date;
  date_accepted: Date | null;
  date_rejected: Date | null;
  date_completed: Date | null;
  note: string | null;
}

export interface OrderAssociatedPeople {
  employee_id: number;
  order_id: number;
}

export interface OrderProduct {
  order_id: number;
  effective_price: number;
  product_id: string;
}

export interface Reservation {
  order_id: number;
  duration_minutes: number;
  seats: string;
}

export interface SeatLimit {
  day: Date;
  seats: number;
}

export interface SeafoodAllowedEarlyConst {
  day: string;
}
