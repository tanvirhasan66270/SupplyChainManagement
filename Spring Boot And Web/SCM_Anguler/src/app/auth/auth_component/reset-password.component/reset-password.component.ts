import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../auth_service/auth-service';
import { ActivatedRoute, Router } from '@angular/router';

@Component({
  selector: 'app-reset-password.component',
  imports: [CommonModule,FormsModule],
  templateUrl: './reset-password.component.html',
  styleUrl: './reset-password.component.css',
})
export class ResetPasswordComponent {


  token = '';
  newPassword = '';
  confirmPassword = '';

  showPassword = false;
  showConfirm = false;
  loading = false;
  success = false;
  errorMessage: string | null = null;

  constructor(
    private auth: AuthService,
    private route: ActivatedRoute,
    private router: Router
  ) { }

  ngOnInit(): void {
    this.token = this.route.snapshot.queryParamMap.get('token') ?? '';
    if (!this.token) {
      this.errorMessage = 'Invalid or missing reset token. Please request a new link.';
    }
  }

  get mismatch(): boolean {
    return !!this.confirmPassword && this.newPassword !== this.confirmPassword;
  }

  submit(): void {
    if (this.mismatch || !this.token) return;

    this.loading = true;
    this.errorMessage = null;

    this.auth.resetPassword({ token: this.token, newPassword: this.newPassword }).subscribe({
      next: () => {
        this.loading = false;
        this.success = true;
        setTimeout(() => this.router.navigate(['/login']), 3000);
      },
      error: (err: any) => {
        this.loading = false;
        this.errorMessage =
          err.status === 400
            ? 'Reset link is invalid or has expired. Please request a new one.'
            : 'Something went wrong. Please try again.';
      }
    });
  }
}
