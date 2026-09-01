import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { QuoteService } from '../../../service/quote.service';
import { QuoteRequestModel } from '../../shared/model/quote_requestModel';
import { CommonModule } from '@angular/common';


@Component({
  selector: 'app-quote-form',
    standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './quote-form.component.html',
  styleUrls: ['./quote-form.component.css']
})
export class QuoteFormComponent implements OnInit {
  
  quoteForm!: FormGroup;
  isSubmitting = false;
  isSuccess = false;
  isError = false;
  errorMessage = '';

  constructor(
    private fb: FormBuilder,
    private quoteService: QuoteService
  ) {}

  ngOnInit(): void {
    this.initForm();
  }

  private initForm(): void {
    this.quoteForm = this.fb.group({
      companyName: ['', [Validators.required, Validators.minLength(2)]],
      contactName: ['', [Validators.required, Validators.minLength(2)]],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.required, Validators.pattern('^[0-9+ ]{7,15}$')]],
      requestType: ['', [Validators.required]],
      productDetails: ['', [Validators.required, Validators.minLength(10)]]
    });
  }

  // ফর্ম সাবমিট মেথড
  onSubmit(): void {
    if (this.quoteForm.invalid) {
      this.markFormGroupTouched(this.quoteForm);
      return;
    }

    this.isSubmitting = true;
    this.isSuccess = false;
    this.isError = false;

    const payload: QuoteRequestModel = this.quoteForm.value;

    this.quoteService.submitRequest(payload).subscribe({ next: (response) => {
        this.isSubmitting = false;
        this.isSuccess = true;
        this.quoteForm.reset({ requestType: '' }); 
      },
      error: (err: any) => {
        this.isSubmitting = false;
        this.isError = true;
        this.errorMessage = err.error?.message || 'Matrix Transmission Failure. Please try again.';
        console.error('SCM Gateway Error:', err);
      }
    });
  }

  isFieldInvalid(fieldName: string): boolean {
    const field = this.quoteForm.get(fieldName);
    return field ? field.invalid && (field.dirty || field.touched) : false;
  }

  private markFormGroupTouched(formGroup: FormGroup) {
    Object.values(formGroup.controls).forEach(control => {
      control.markAsTouched();
      if ((control as any).controls) {
        this.markFormGroupTouched(control as FormGroup);
      }
    });
  }
}