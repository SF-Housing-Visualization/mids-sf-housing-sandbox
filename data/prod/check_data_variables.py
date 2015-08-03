import os
import sys
import pandas

data_var_fname = 'data_variables.csv'
source_dir = 'values'

data_var = pandas.read_csv(data_var_fname)
data_var.sort('LogicalCategory', inplace=True)

cati = ''

for index, row in data_var.iterrows():
	category = row['LogicalCategory']
	if category != cati:
		print('#############################')
		print('### ' + category)
		print('-----------------------------')
	file_prefix = row['GroupID']
	var_id = row['VariableID']
	var_name = row['VariableName']
	var_des = row['VariableDescription']
	data = pandas.read_csv(source_dir + '/' + file_prefix + '.csv')[var_id]
	print("%s \n%s...\n%s" %(var_name, list(data[0:4]), var_des))
	print('-----------------------------')
	cati = category

