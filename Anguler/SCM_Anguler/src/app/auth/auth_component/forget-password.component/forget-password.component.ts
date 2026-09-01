import { Component } from '@angular/core';
import { AuthService } from '../../auth_service/auth-service';
import { ActivatedRoute, Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-forget-password.component',
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './forget-password.component.html',
  styleUrl: './forget-password.component.css',
})
export class ForgetPasswordComponent {
  email = '';
  loading = false;
  successMessage: string | null = null;
  errorMessage: string | null = null;

  constructor(private auth: AuthService) {}

  submit(): void {
    this.loading = true;
    this.successMessage = null;
    this.errorMessage = null;

    this.auth.forgotPassword({ email: this.email }).subscribe({
      next: () => {
        this.loading = false;
        this.successMessage = `A password reset link has been sent to ${this.email}.`;
      },
      error: () => {
        this.loading = false;
        this.errorMessage = 'No account found with that email address.';
      },
    });
  }

  scrollTo(id: string): void {
    document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });
  }
}
