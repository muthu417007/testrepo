public inherited sharing class NavigationLinkSetPickList extends VisualEditor.DynamicPickList {

    public static final String STORE_NAME = 'Bodewell Store';

    public override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
            '',
            ''
        );
        return defaultValue;
    }

    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
        picklistValues.addRow(getDefaultValue());

        List<NavigationLinkSet> navigationLinkSetList = [
            SELECT MasterLabel, DeveloperName
            FROM NavigationLinkSet
            WHERE Network.Name = :STORE_NAME
        ];

        for (NavigationLinkSet navigationLinkSet : navigationLinkSetList) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(
                navigationLinkSet.MasterLabel,
                navigationLinkSet.DeveloperName
            );
            picklistValues.addRow(value);
        }
        return picklistValues;
    }
}