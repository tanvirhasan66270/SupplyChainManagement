import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CategoryService } from '../../../service/category.service';
import { CategoryRequestModel, CategoryResponseModel } from '../../shared/model/category';

@Component({
  selector: 'app-category',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './category.component.html',
  styleUrl: './category.component.css',
})
export class CategoryComponent implements OnInit {

  categories: CategoryResponseModel[] = [];

  category: CategoryRequestModel = {
    categoryName: '',
    description: ''
  };

  isEdit = false;
  currentEditId: number | null = null;
  isDrawerOpen = false;

  constructor(
    private service: CategoryService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit() {
    this.loadCategories();
  }

  // =====================================================
  // DRAWER CORE CONTROLS
  // =====================================================
  openDrawer() {
    this.reset();
    this.isEdit = false;
    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  closeDrawer() {
    this.isDrawerOpen = false;
    this.reset();
    this.cdr.markForCheck();
  }

  // =====================================================
  // DATA LOADERS
  // =====================================================
  loadCategories() {
    this.service.getAll().subscribe({
      next: (data) => {
        this.categories = data || [];
        this.cdr.markForCheck();
      }
    });
  }

  // =====================================================
  // CRUD ACTIONS
  // =====================================================
  save() {
    if (!this.category.categoryName || this.category.categoryName.trim().length === 0) {
      alert("Please provide a valid category name.");
      return;
    }

    if (this.isEdit && this.currentEditId !== null) {
      this.service.update(this.currentEditId, this.category).subscribe({
        next: () => {
          alert("Category node updated successfully!");
          this.closeDrawer();
          this.loadCategories();
        },
        error: (err: any) => {
          console.error('Category update failed:', err);
          alert(err.error?.message || 'Category update failed. Verify server data rules.');
        }
      });
    } else {
      this.service.save(this.category).subscribe({
        next: () => {
          alert("New asset category committed successfully!");
          this.closeDrawer();
          this.loadCategories();
        },
        error: (err: any) => {
          console.error('Category configuration failed:', err);
          alert(err.error?.message || 'Category deployment configuration failed.');
        }
      });
    }
  }

  edit(c: CategoryResponseModel) {
    this.currentEditId = c.id;
    this.isEdit = true;

    this.category = {
      categoryName: c.categoryName,
      description: c.description
    };

    this.isDrawerOpen = true;
    this.cdr.markForCheck();
  }

  delete(id: number) {
    if (confirm("Purge this category and all its item associations?")) {
      this.service.delete(id).subscribe({
        next: () => {
          alert("Category node removed successfully.");
          this.loadCategories();
        },
        error: (err: any) => {
          console.error('Category deletion failed:', err);
          alert('Failed to remove category record.');
        }
      });
    }
  }

  reset() {
    this.category = {
      categoryName: '',
      description: ''
    };
    this.isEdit = false;
    this.currentEditId = null;
  }
}
