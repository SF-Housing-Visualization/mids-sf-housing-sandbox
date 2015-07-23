# Structure

Directory structure for production data looks like this:

	data/prod/
		data_variables.csv
		data_geos.csv
		values/
			GroupA.csv
			GroupB.csv
			...

This is the sructure of the data that the visualizaiton will ultimately use. We need to get our data in to this format.

There are three csv's. One which has the actual data (data_values.csv), one which contains information about each variable (data_variables.csv), and one which contains information about geographic locations (data_geos.csv).

We can denormalize these in to a single table for consumption by the data viz, but these should be kept as three different csv's so, for example, if we change the description of a variable we only have to do it in one place.

## data_values.csv

This actually contains the values of the data

The fields are:

<ol>
	<li>GeoID: this corresponds to Id2 from the census data, like 6001, should match GeoId in data_geo.csv</li>
	<li>VariableID: the id we have given to the variable, should match VariableId in data_variables.csv</li>
	<li>Date: this should be a date of format yyyy-mm-dd</li>
	<li>Value: the value of the variable, for that geo, for that date</li>
</ol>

## data_variables.csv

This contains information about each variable used in our visualization

<ol>
	<li>VariableID: the id we have given the variable</li>
	<li>VariableName: the name of the variable as we want it to appear in the visualizaiton</li>
	<li>VariableDescription: longer explanation of the variable as it will appear in the explanatory text</li>
</ol>

## data_geos.csv

This contains information about each geographic location

<ol>
	<li>GeoID: this corresponds to Id2 from the census data, like 6001</li>
	<li>LongID: this corresponds to Id1 form the census data, 0500000US06001</li>
	<li>LongName: this corresponds to Geography from the census data, like "Alameda County, California"</li>
	<li>ShortName: this the geography name as we want it displayed in th viz, like "Alameda"</li>
</ol>
