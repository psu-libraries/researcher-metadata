import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    depositId: String, 
    checkUrl: String 
  }

  static targets = [ "loading" ]

  connect() {
    this.pollCount = 0;
    this.maxPolls = 60;
  }

  submit(event) {
    event.preventDefault();
    const form = this.element;

    this.setLoadingState(true);

    fetch(form.action, {
      method: 'post',
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
      }
    })
    .then(response => {
      if (!response.ok) throw new Error('Submission failed');
      return response.json();
    })
    .then(data => {
      if (!data.deposit_id || !data.check_url) {
        throw new Error('Invalid response from server');
      }

      this.depositIdValue = data.deposit_id;
      this.checkUrlValue = data.check_url;

      this.startPolling();
    })
    .catch(error => {
      console.error(error);
    });
  }

  startPolling() {
    this.poll();
  }
  
  async poll() {
    try {
      const response = await fetch(this.checkUrlValue, {
        headers: {
          'Accept': 'application/json'
        }
      });
      const data = await response.json();
      
      if (!response.ok) {
        this.showFailureMessage()
      }
      
      switch (data.status) {
        case 'completed':
          this.handleComplete(data);

          break;
        case 'failed':
          this.handleFailed(data);

          break;
        default:
          this.handlePending(data);

          break;
      }
    } catch (error) {
      console.error('Polling error:', error);
      this.showFailureMessage();
    }
  }

  handleComplete(data) {
    if (this.pollTimer) clearTimeout(this.pollTimer);
    this.dispatch('complete', { detail: data });
    setTimeout(() => {
      window.location.href = data.edit_url;
    }, 500);
  }
  
  handleFailed(data) {
    if (this.pollTimer) clearTimeout(this.pollTimer);
    
    this.dispatch('error', { detail: data.error });
    console.log('Error: ' + data.error)
    this.showFailureMessage();
  }

  handlePending(data) {
    this.pollCount++;
    
    if (this.pollCount >= this.maxPolls) {
      this.dispatch('timeout', {});
      this.showFailureMessage()
      return;
    }
    
    const delay = this.calculateBackoffDelay();
    this.pollTimer = setTimeout(() => this.poll(), delay);
  }
  
  calculateBackoffDelay() {
    if (this.pollCount < 10) return 1000;
    if (this.pollCount < 30) return 2000;
    return 5000;
  }

  showFailureMessage() {
    alert('Something went in creating a Scholarsphere deposit. Please navigate to https://scholarsphere.psu.edu/');
  }

  setLoadingState(loading) {
    const submitBtn = this.element.querySelector('button[type="submit"]');
    if (submitBtn) {
      submitBtn.disabled = loading;
    }
    this.loadingTarget.classList.remove('d-none')
  }
}