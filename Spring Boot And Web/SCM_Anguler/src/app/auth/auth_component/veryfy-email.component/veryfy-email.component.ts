import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../auth_service/auth-service';

type VerifyState = 'loading' | 'success' | 'error' | 'no-token';

@Component({
  selector: 'app-veryfy-email.component',
  imports: [CommonModule,FormsModule],
  templateUrl: './veryfy-email.component.html',
  styleUrl: './veryfy-email.component.css',
})
export class VeryfyEmailComponent {


   state: VerifyState = 'loading';
  errorMessage = '';
  countdown = 5;
  private timer: any;
 
  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private auth: AuthService
  ) { }
 
  ngOnInit(): void {
    const token = this.route.snapshot.queryParamMap.get('token');
 
    if (!token) {
      this.state = 'no-token';
      return;
    }
 
    this.auth.verifyEmail(token).subscribe({
      next: () => {
        this.state = 'success';
        this.startCountdown();
      },
      error: (err: any) => {
        this.state = 'error';
        this.errorMessage =
          err.status === 400 || err.status === 409
            ? err.error ?? 'This verification link is invalid or has already been used.'
            : 'Something went wrong. Please request a new verification email.';
      }
    });
  }
 
  private startCountdown(): void {
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.timer);
        this.router.navigate(['/login']);
      }
    }, 1000);
  }
 
  goToLogin(): void {
    clearInterval(this.timer);
    this.router.navigate(['/login']);
  }
 
  ngOnDestroy(): void {
    clearInterval(this.timer);
  }


}
