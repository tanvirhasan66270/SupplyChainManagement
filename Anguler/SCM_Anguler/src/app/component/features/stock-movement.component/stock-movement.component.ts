import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  StockMovementRequestModel,
  StockMovementResponseModel,
} from '../../shared/model/stock-movement';
import { StockMovementService } from '../../../service/stock-movement.service';
import { AddProductService } from '../../../service/add-product.service';
import { WarehouseService } from '../../../service/warehouse.service';
import { StorageService } from '../../../auth/auth_service/storage.service';
import { InventoryService } from '../../../service/inventory.service';

@Component({
  selector: 'app-stock-movement',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './stock-movement.component.html',
  styleUrl: './stock-movement.component.css',
})
export class StockMovementComponent implements OnInit {
  movements: StockMovementResponseModel[] = [];
  products: any[] = [];
  warehouses: any[] = [];
  stocks: any[] = []; 
  currentUserId: number = 0;

  errorMessage: string | null = null;
  isDrawerOpen = false;

  formModel: StockMovementRequestModel = {
    productId: 0,
    warehouseId: 0,
    sourceWarehouseId: null,
    movementType: 'INWARD',
    quantity: 0,
    referenceId: '',
    performedBy: 0,
    remarks: '',
  };

  constructor(
    private service: StockMovementService,
    private productService: AddProductService,
    private warehouseService: WarehouseService,
    private stockService: InventoryService,
    private storage: StorageService,
    private cdr: ChangeDetectorRef,
  ) {}

  ngOnInit() {
    const user = this.storage.getUser();
    if (user) {
      this.currentUserId = user.userId;
      this.formModel.performedBy = user.userId;
    }
    this.loadMovements();
    this.loadProducts();
    this.loadWarehouses();
    this.loadStocks(); 
  }

  loadMovements() {
    this.service.findAll().subscribe({
      next: (data) => {
        this.movements = data || [];
        this.cdr.markForCheck();
      },
      error: (err: any) => this.handleErrorLog(err),
    });
  }

  loadProducts() {
    this.productService.findAll().subscribe({ next: (data) => (this.products = data || []) });
  }

  loadWarehouses() {
    this.warehouseService.getAll().subscribe({ next: (data) => (this.warehouses = data || []) });
  }

  loadStocks() {
    this.stockService.findAll().subscribe({ 
      next: (data) => {
        this.stocks = data || [];
        this.cdr.markForCheck();
      } 
    });
  }

  get availableProductsForMovement(): any[] {
    return this.products.filter(product => {
      const stockItem = this.stocks.find(s => s.productId === product.id || (s.product && s.product.id === product.id));
      const qty = stockItem ? (stockItem.quantityOnHand || stockItem.availableSellable || 0) : 0;
      return qty >= 1;
    });
  }

  onProductChange() {
    if (!this.formModel.productId || +this.formModel.productId === 0) {
      this.formModel.warehouseId = 0;
      return;
    }

    const matchedStock = this.stocks.find(s => 
      s.productId === +this.formModel.productId || 
      (s.product && s.product.id === +this.formModel.productId)
    );

    if (matchedStock) {
      const whId = matchedStock.warehouseId || (matchedStock.warehouse ? matchedStock.warehouse.id : 0);
      if (whId) {
        this.formModel.warehouseId = whId;
      }
    }
    this.cdr.markForCheck();
  }

  getSelectedProductStock(): string {
    if (!this.formModel.productId || +this.formModel.productId === 0) {
      return '';
    }
    const matchedStock = this.stocks.find(s => 
      s.productId === +this.formModel.productId || 
      (s.product && s.product.id === +this.formModel.productId)
    );
    if (matchedStock) {
      return `${matchedStock.quantityOnHand || matchedStock.availableSellable || 0} Units`;
    }
    return '0 Units';
  }

  onMovementTypeChange() {
    // No longer clearing sourceWarehouseId, as it's visible and available for all transaction types
  }

  getTargetWarehouseName(): string {
    if (!this.formModel.warehouseId) return 'Auto-filled from inventory stock...';
    const wh = this.warehouses.find(w => w.id === +this.formModel.warehouseId);
    return wh ? wh.name : 'Selected Inventory Warehouse';
  }

  openDrawer() {
    this.resetForm();
    this.loadStocks(); 
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  closeDrawer() {
    this.isDrawerOpen = false;
    this.resetForm();
    this.cdr.markForCheck();
  }

  submitMovement() {
    this.errorMessage = null;

    if (
      !this.formModel.productId ||
      +this.formModel.productId === 0 ||
      !this.formModel.warehouseId ||
      +this.formModel.warehouseId === 0
    ) {
      this.errorMessage =
        'Validation Fault: Product specs and Target Warehouse node must be assigned.';
      this.cdr.markForCheck();
      return;
    }

    if (this.formModel.sourceWarehouseId && +this.formModel.warehouseId === +this.formModel.sourceWarehouseId) {
      this.errorMessage =
        'Business Conflict: Source warehouse and Target destination warehouse cannot be identical.';
      this.cdr.markForCheck();
      return;
    }

    const payload: StockMovementRequestModel = {
      productId: +this.formModel.productId,
      warehouseId: +this.formModel.warehouseId,
      sourceWarehouseId: this.formModel.sourceWarehouseId
        ? +this.formModel.sourceWarehouseId
        : null,
      movementType: this.formModel.movementType,
      quantity: +this.formModel.quantity,
      referenceId: this.formModel.referenceId.trim(),
      performedBy: +this.formModel.performedBy,
      remarks: this.formModel.remarks?.trim() || '',
    };

    this.service.logMovement(payload).subscribe({
      next: () => {
        alert('Stock Transaction Logged successfully into ledger maps.');
        this.closeDrawer();
        this.loadMovements();
      },
      error: (err: any) => this.handleErrorLog(err),
    });
  }

  deleteLog(id: number) {
    if (
      confirm(
        'Are you sure you want to delete this log transaction? (Inventory reconciliation needs to be handled manually)',
      )
    ) {
      this.service.delete(id).subscribe({
        next: () => {
          alert('Ledger item removed.');
          this.loadMovements();
        },
        error: (err: any) => alert(err.error?.message || err.message),
      });
    }
  }

  private handleErrorLog(err: any) {
    console.error('SCM Ledger Exception Stack:', err);
    this.errorMessage =
      err.error?.message || err.message || '400 Bad Request: Parameter serialization constraint.';
    this.cdr.markForCheck();
  }

  resetForm() {
    this.formModel = {
      productId: 0,
      warehouseId: 0,
      sourceWarehouseId: null,
      movementType: 'INWARD',
      quantity: 0,
      referenceId: '',
      performedBy: this.currentUserId,
      remarks: '',
    };
    this.errorMessage = null;
  }
}