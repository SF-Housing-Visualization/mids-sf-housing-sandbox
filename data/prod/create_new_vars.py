import os
import sys
import pandas

fdir = '/Users/rossboberg/Documents/MIDS/dataviz209/final-project/mids-sf-housing-sandbox/data/prod/values_orig'
newdir = '/Users/rossboberg/Documents/MIDS/dataviz209/final-project/mids-sf-housing-sandbox/data/prod/values'

exclude = ['.DS_Store']
dontpercent = ['B25092.csv', 'B25097.csv', 'B25099.csv']

os.listdir(fdir)

total_col = 'Estimate; Total:'
id_vars = ['GeoID', 'Date']

for fname in [f for f in os.listdir(fdir) if not (f in exclude)]:
	df = pandas.read_csv(fdir + '/' + fname)
	cols = df.columns.values
	if (total_col in cols) and not (fname in dontpercent):
		col_sub = [c for c in cols if ('Estimate' in c) & (c != total_col)]
		df_pct = df[col_sub].astype('float').div(df[total_col].astype('float'), axis='index')
		col_new = [c.replace('Estimate; ', '') for c in col_sub]
		df_pct.columns = col_new
		df_id = df[id_vars]
		df_new = df_id.merge(df_pct, right_index=True, left_index=True)
		fname_new = newdir + '/' + fname.replace('.csv','') + '_percent.csv'
		df_new.to_csv(fname_new, index=False, float_format='%.4f')
	else:
		col_sub = [c for c in cols if ('Estimate' in c)]
		if len(col_sub) > 0:
			df_new = df[col_sub]
			col_new = [c.replace('Estimate; ', '') for c in col_sub]
			df_new.columns = col_new
			df_id = df[id_vars]
			df_new = df_id.merge(df_new, right_index=True, left_index=True)
			fname_new = newdir + '/' + fname.replace('.csv','') + '.csv'
			df_new.to_csv(fname_new, index=False, float_format='%.4f')
		else:
			fname_new = newdir + '/' + fname.replace('.csv','') + '.csv'
			df.to_csv(fname_new, index=False, float_format='%.4f')


