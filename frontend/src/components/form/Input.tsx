import * as React from 'react';

import { IConstraint, IError, IInputChangeHandler } from '../../types';

import FieldFeedbackPanel from './FieldFeedbackPanel';

const NoConstraint: IConstraint = {
  message: '',
  validate: v => true
};


export default ({type, object, error, name, id, constraint = NoConstraint, label, onChange}: {type: string, object: any, error: IError, name?: string, id?: string, constraint?: IConstraint, label: string, onChange: IInputChangeHandler }) => {

  const handleOnChange = event => {
    const { value } = event.target;

    // run validation (if any)
    let error = null;
    const fieldError = constraint.validate(value) === false ? { field: name, message: constraint.message } : null;

    // invoke callback
    onChange(name, value, fieldError);
  };

  const value = object[name];
  const fieldError = error && error.fieldErrors[name];
  const valid = !fieldError && value !== null && value !== undefined;

  const cssGroup = `form-group ${fieldError ? 'has-error' : ''}`;

  return (
    <div className={cssGroup}>
      <label className='col-sm-2 control-label'>{label}</label>

      <div className='col-sm-10'>
        <input type={type} id={id} name={name} className='form-control' value={value} onChange={handleOnChange} />

         <FieldFeedbackPanel valid={valid} fieldError={fieldError} />
      </div>
    </div>
  );
};
