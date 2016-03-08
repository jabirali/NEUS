
program test_config
  use mod_structure

  type(structure) :: bilayer
  bilayer = structure('test.conf')

  !call bilayer % push_back('superconductor')
  !call bilayer % conf_back('temperature', '0.10')
  !call bilayer % conf_back('scattering',  '0.05')
  !call bilayer % conf_back('length',      '0.75')
  !call bilayer % conf_back('coupling',    '0.25')

  !call bilayer % push_back('ferromagnet')
  !call bilayer % conf_back('temperature', '0.10')
  !call bilayer % conf_back('scattering',  '0.05')
  !call bilayer % conf_back('length',      '0.50')

  write(*,*) bilayer % a % material_b % thouless

  call bilayer % update
end program