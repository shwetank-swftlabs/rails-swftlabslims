import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    reactors: Array,
    isStandaloneBatch: String, // "true" or "false"
  };

  static targets = [
    'feedstockTypeSelect',
    'batchNumberInput',
    'nopReactionDateInput',
    'reactorSelect',
    'reactionTypeSelect',
  ];

  connect() {
    console.log('NopProcessFormController connected');
    console.log(this.reactorsValue);

    if (this.reactorSelectTarget.value) {
      this.setSelectedReactorId(parseInt(this.reactorSelectTarget.value, 10));
    }
    // Initialize the previous date value with the current value
    if (this.hasNopReactionDateInputTarget) {
      this.previousNopReactionDateValue = this.nopReactionDateInputTarget.value;
    }
  }

  setSelectedReactorId(reactorId) {
    this.selectedReactorId = reactorId;
  }

  storeNopReactionDateValue(event) {
    // Store the current value before user changes it
    this.previousNopReactionDateValue = event.target.value;
  }

  resetSelectFeedstockType() {
    this.feedstockTypeSelectTarget.value = '';
  }

  resetBatchNumber() {
    this.batchNumberInputTarget.value = '';
  }

  resetReactionType() {
    this.reactionTypeSelectTarget.value = '';
  }

  reactorSelectionChanged(event) {
    const reactorId = parseInt(this.reactorSelectTarget.value, 10);

    // Reset the form fields
    this.resetSelectFeedstockType();
    this.resetBatchNumber();
    this.resetReactionType();

    if (!reactorId) {
      // user selected "Please select a reactor"
      this.selectedReactor = null;
      return;
    }

    if (!this.reactorsValue.find((r) => r.id === reactorId)) {
      alert(
        'Could not find the reactor object. Please refresh the page and try again. If the problem persists, please contact support.'
      );
      return;
    }

    this.setSelectedReactorId(reactorId);
  }

  handleNopReactionDateChange(event) {
    // Check if feedstock type is not selected
    if (!this.feedstockTypeSelectTarget.value) {
      this.nopReactionDateInputTarget.value = this.previousNopReactionDateValue;
      alert('Please select a feedstock type first.');
      return;
    }

    this.setBatchNumber();
  }

  feedstockTypeChanged(event) {
    this.resetBatchNumber();

    if (!this.selectedReactorId) {
      alert('Please select a reactor first.');
      this.resetSelectFeedstockType();
      return;
    }

    if (!this.feedstockTypeSelectTarget.value) {
      return;
    }

    this.setBatchNumber();
  }

  async setBatchNumber() {
    const feedstockType = this.feedstockTypeSelectTarget.value;
    const reactorId = this.selectedReactorId;
    const isStandaloneBatch = this.isStandaloneBatchValue === 'true';

    const url =
      `/experiments/nop_processes/batch_number?` +
      new URLSearchParams({
        feedstock_type: feedstockType,
        reactor_id: reactorId,
        is_standalone_batch: isStandaloneBatch,
        nop_reaction_date: this.nopReactionDateInputTarget.value,
      });

    return fetch(url, {
      method: 'GET',
      headers: {
        Accept: 'application/json',
      },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`Request failed with status ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        this.batchNumberInputTarget.value = data.batch_number;
      })
      .catch((error) => {
        alert(
          'Error fetching batch number. Please refresh the page and try again. If the problem persists, please contact support or enter the batch number manually.'
        );
        console.error('Error fetching batch number:', error);
        throw error;
      });
  }
}
