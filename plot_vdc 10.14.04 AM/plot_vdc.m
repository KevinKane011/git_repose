function plot_vdc(vdc_file)

if exist('vdc_file', 'var') == 0
    vdc_file = uigetfile('*.vdc', 'Select a *.vdc file');
end

vdc = VDC(vdc_file);

show_stacked_maps(vdc.correction_factor_stack)
title([vdc.sensor_serial_number ' vdc'])
saveas(gcf, ['vdc_' vdc.sensor_serial_number '.png'])

