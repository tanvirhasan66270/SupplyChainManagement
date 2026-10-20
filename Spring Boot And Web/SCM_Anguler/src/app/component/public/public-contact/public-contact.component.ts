import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-public-contact',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './public-contact.component.html',
  styleUrls: ['./public-contact.component.css']
})
export class PublicContactComponent {
  feedback = { name: '', email: '', phone: '', subject: '', message: '' };
  formSubmitted = false;

  submitForm(): void {
    if (!this.feedback.name || !this.feedback.email || !this.feedback.message) {
      alert('Please fill out all required fields (Name, Email, Message).');
      return;
    }
    this.formSubmitted = true;
    this.feedback = { name: '', email: '', phone: '', subject: '', message: '' };
    setTimeout(() => { this.formSubmitted = false; }, 5000);
  }
}
