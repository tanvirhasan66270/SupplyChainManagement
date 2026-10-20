
export interface StockMovementRequestModel {
    productId: number;
    warehouseId: number;
    sourceWarehouseId?: number | null;
    movementType: 'INWARD' | 'OUTWARD' | 'TRANSFER' | 'ADJUSTMENT' | string;
    quantity: number;
    referenceId: string;
    performedBy: number;
    remarks?: string;
}

export interface StockMovementResponseModel {
    id: number;
    productId: number;
    productName: string;
    warehouseId: number;
    warehouseName: string;
    sourceWarehouseId?: number | null;
    sourceWarehouseName?: string | null;
    movementType: 'INWARD' | 'OUTWARD' | 'TRANSFER' | 'ADJUSTMENT' | string;
    quantity: number;
    referenceId: string;
    performedBy: number;
    performedByName: string;
    movedAt: string;
    remarks: string;
}
