// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from 'controllers/application';
import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading';
import NopProcessFormController from 'controllers/nop_process_form_controller';

application.register('nop_process_form', NopProcessFormController);
eagerLoadControllersFrom('controllers', application);
