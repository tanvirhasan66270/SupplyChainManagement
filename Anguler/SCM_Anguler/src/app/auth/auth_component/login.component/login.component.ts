import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LoginRequest } from '../../Model/authModel';
import { AuthService } from '../../auth_service/auth-service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login.component',
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css',
})
export class LoginComponent {
  dto: LoginRequest = { email: '', password: '' };

  showPassword = false;
  loading = false;
  rememberMe = false;
  errorMessage: string | null = null;

  constructor(
    private auth: AuthService,
    private router: Router,
  ) { }

  fillDemo(email: string, password: string): void {
    this.dto.email = email;
    this.dto.password = password;
  }

  login(): void {
    this.loading = true;
    this.errorMessage = null;

    this.auth.login(this.dto).subscribe({
      next: (res) => {
        this.loading = false;

        switch (res.role) {

          case 'ADMIN':
            this.navigateAndReload('/dashboard/admin');
            break;

          case 'MANAGER':
            this.navigateAndReload('/dashboard/manager');
            break;

          case 'CUSTOMER':
            this.navigateAndReload('/dashboard/customer');
            break;

          case 'SUPPLIER':
            this.navigateAndReload('/dashboard/supplier');
            break;

          case 'DRIVER':
            this.navigateAndReload('/dashboard/driver');
            break;

          case 'PROCUREMENT':
            this.navigateAndReload('/dashboard/procurement');
            break;

          case 'QC_INSPECTOR':
            this.navigateAndReload('/dashboard/qc-inspector');
            break;

          case 'LOGISTICS_OFFICER':
            this.navigateAndReload('/dashboard/logistics');
            break;

          case 'COMMERCIAL_OFFICER':
            this.navigateAndReload('/dashboard/commercial');
            break;

          case 'SALES_OFFICER':
            this.navigateAndReload('/dashboard/sales');
            break;

          default:
            this.navigateAndReload('/dashboard');
        }
      },
      error: (err: any) => {
        this.loading = false;
        this.errorMessage =
          err.status === 401
            ? 'Invalid email or password.'
            : err.status === 403
              ? 'Your account is not verified or has been disabled.'
              : 'Something went wrong. Please try again.';
      },
    });
  }

  private navigateAndReload(url: string): void {
    this.router.navigate([url]).then(() => {
      window.location.reload();
    });
  }
}
