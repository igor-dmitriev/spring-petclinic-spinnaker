import * as React from 'react';

const MenuItem = ({active, url, title, children}: { active: boolean, url: string, title: string, children?: any }) => (
  <li className={active ? 'active' : ''}>
    <a href={url} title={title}>{children}</a>
  </li>
);

export default ({name}: { name: string }) => (
  <nav className='navbar navbar-default' role='navigation'>
    <div className='container'>
      <div className='navbar-header'>
        <a className='navbar-brand' href='/'><span></span></a>
        <button type='button' className='navbar-toggle' data-toggle='collapse' data-target='#main-navbar'>
          <span className='icon-bar'></span>
          <span className='icon-bar'></span>
          <span className='icon-bar'></span>
        </button>
      </div>
      <div className='navbar-collapse collapse' id='main-navbar'>
        <ul className='nav navbar-nav navbar-right'>
          <MenuItem active={name === '/'} url='/' title='home page'>
            <span className='glyphicon glyphicon-home' aria-hidden='true'></span>&nbsp;
                    <span>HOME</span>
          </MenuItem>

          <MenuItem active={name.startsWith('/#/owners')} url='/#/owners/list' title='find owners'>
            <span className='glyphicon glyphicon-search' aria-hidden='true'></span>&nbsp;
                    <span>FIND OWNERS</span>
          </MenuItem>

          <MenuItem active={name === 'vets'} url='/#/vets' title='veterinarians'>
            <span className='glyphicon glyphicon-th-list' aria-hidden='true'></span>&nbsp;
                    <span>VETERINARIANS</span>
          </MenuItem>
        </ul>
      </div>
    </div>
  </nav>
);
