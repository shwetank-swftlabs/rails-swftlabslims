import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    reactors: Array,
  };

  static targets = [
    'newStandaloneBatchYesRadio',
    'newStandaloneBatchNoRadio',
    'feedstockTypeSelect',
    'batchNumberInput',
    'nopReactionDateInput',
    'reactorSelect',
  ];

  connect() {
    const reactors = this.reactorsValue;
    this.selectedReactor = this.reactorSelectTarget.value
      ? reactors.find((r) => r.reactor_id === +this.reactorSelectTarget.value)
      : null;
    this.initialNopReactionDateValue = this.nopReactionDateInputTarget.value;
  }

  storeNopReactionDateValue(event) {
    // Store the current value before user changes it
    this.previousNopReactionDateValue = event.target.value;
  }

  resetNewStandaloneBatch() {
    this.newStandaloneBatchYesRadioTarget.checked = true;
  }

  selectNoEffluentReuse() {
    this.newStandaloneBatchYesRadioTarget.checked = true;
  }

  resetSelectFeedstockType() {
    this.feedstockTypeSelectTarget.value = '';
  }

  resetBatchNumber() {
    this.batchNumberInputTarget.value = '';
  }

  reactorSelectionChanged(event) {
    const reactorId = parseInt(this.reactorSelectTarget.value, 10);
    this.resetSelectFeedstockType();
    this.resetNewStandaloneBatch();
    this.batchNumberInputTarget.value = '';

    if (!reactorId) {
      // user selected "Please select a reactor"
      this.selectedReactor = null;
      return;
    }

    const selectedReactor = this.reactorsValue.find(
      (r) => r.reactor_id === reactorId
    );

    if (!selectedReactor) {
      alert(
        'Could not find the reactor object. Please refresh the page and try again. If the problem persists, please contact support.'
      );
      return;
    }

    this.selectedReactor = selectedReactor;
    console.log('Selected reactor:', this.selectedReactor);
  }

  newStandaloneBatchChanged(event) {
    alert('Setting up batches with reuse of effluents is work in progress.');
    this.newStandaloneBatchYesRadioTarget.checked = true;

    return;
  }

  handleNopReactionDateChange(event) {
    // Check if feedstock type is not selected
    if (!this.feedstockTypeSelectTarget.value) {
      this.nopReactionDateInputTarget.value = this.initialNopReactionDateValue;
      alert('Please select a feedstock type first.');
      return;
    }

    this.setBatchNumber();
  }

  feedstockTypeChanged(event) {
    this.resetBatchNumber();

    if (!this.selectedReactor) {
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
    if (!this.selectedReactor) {
      console.warn('Cannot set batch number: reactor not selected');
      return;
    }

    const feedstockType = this.feedstockTypeSelectTarget.value;
    const reactorId = this.selectedReactor.reactor_id;
    const isReusingEffluent = this.newStandaloneBatchNoRadioTarget.checked;

    const url =
      `/experiments/nop_processes/batch_number?` +
      new URLSearchParams({
        feedstock_type: feedstockType,
        reactor_id: reactorId,
        is_reusing_effluent: isReusingEffluent,
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
