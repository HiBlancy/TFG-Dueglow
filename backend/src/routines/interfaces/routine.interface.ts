export interface RoutineProduct {
  productId: string; // Referencia al producto
  order: number; // Posicion en la rutina
}

export interface Routine {
  _id: string;
  userId: string; // Referencia al usuario propietario
  name: string; // Nombre de la rutina
  time: 'morning' | 'night'; // Manana o noche
  daysOfWeek: string[]; // ['monday', 'tuesday', ...]
  products: RoutineProduct[]; // Array de productos en orden
  createdAt: Date;
  updatedAt: Date;
}
