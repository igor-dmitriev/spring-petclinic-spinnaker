import * as React from 'react';

import { IOwner } from '../../types';
import {Link} from 'react-router';

const renderRow = (owner: IOwner) => (
  <tr key={owner.id}>
    <td>
       <Link to={`/owners/${owner.id}`}><span>{owner.firstName} {owner.lastName}</span></Link>
  </td>
    <td className='hidden-sm hidden-xs'>{owner.address}</td>
    <td>{owner.city}</td>
    <td>{owner.telephone}</td>
    <td className='hidden-xs'>{owner.pets.map(pet => pet.name).join(', ')}</td>
  </tr>
);

const renderOwners = (owners: IOwner[]) => (
  <section>
    <h2>{owners.length} Owners found</h2>
    <table id='owners-table' className='table table-striped'>
      <thead>
        <tr>
          <th>Name</th>
          <th className='hidden-sm hidden-xs'>Address</th>
          <th>City</th>
          <th>Telephone</th>
          <th className='hidden-xs'>Pets</th>
        </tr>
      </thead>
      <tbody>
        {owners.map(renderRow)}
      </tbody>
    </table>
  </section>
);

const emptyOwners = () => (
    <section>
        <table className='table table-striped'>
            <thead>
            <tr>
                <th>Name</th>
                <th className='hidden-sm hidden-xs'>Address</th>
                <th>City</th>
                <th>Telephone</th>
                <th className='hidden-xs'>Pets</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </section>
);

export default ({owners}: { owners: IOwner[] }) => owners ? renderOwners(owners) : emptyOwners();
