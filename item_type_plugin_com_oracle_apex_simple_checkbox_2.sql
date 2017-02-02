set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_release=>'5.0.3.00.03'
,p_default_workspace_id=>1672527800524517
,p_default_application_id=>107
,p_default_owner=>'TEST'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/item_type/com_oracle_apex_simple_checkbox_2
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(17124832905782365193)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'COM.ORACLE.APEX.SIMPLE_CHECKBOX_2'
,p_display_name=>'Simple Checkbox 2 (With Switch Support)'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'--===============================================================================',
'-- Renders the Simple Checkbox item type based on the configuration of the page item.',
'--===============================================================================',
'function render_simple_checkbox (',
'    p_item                in apex_plugin.t_page_item,',
'    p_plugin              in apex_plugin.t_plugin,',
'    p_value               in varchar2,',
'    p_is_readonly         in boolean,',
'    p_is_printer_friendly in boolean )',
'    return apex_plugin.t_page_item_render_result',
'is',
'    -- Use named variables instead of the generic attribute variables',
'    l_checked_value    varchar2(255)  := nvl(p_item.attribute_01, ''Y'');',
'    l_unchecked_value  varchar2(255)  := p_item.attribute_02;',
'    l_checked_label    varchar2(4000) := p_item.attribute_03;',
'    l_bootstrap_switch varchar2(10)   := p_item.attribute_04;',
'    l_on_colour        varchar2(30)   := p_item.attribute_05;',
'    l_off_colour       varchar2(30)   := p_item.attribute_06;',
'    l_on_text          varchar2(20)   := p_item.attribute_07;',
'    l_off_text         varchar2(20)   := p_item.attribute_08;',
'    l_size             varchar2(20)   := p_item.attribute_09;',
'',
'    l_name             varchar2(30);',
'    l_value            varchar2(255);',
'    l_checkbox_postfix varchar2(8);',
'    ',
'    v_html             varchar2(4000); -- Used for temp HTML/JS',
'    l_result           apex_plugin.t_page_item_render_result;',
'begin',
'    -- if the current value doesn''t match our checked and unchecked value',
'    -- we fallback to the unchecked value ',
'    if p_value in (l_checked_value, l_unchecked_value) then',
'        l_value := p_value;',
'    else',
'        l_value := l_unchecked_value;',
'    end if;',
'',
'    if p_is_readonly or p_is_printer_friendly then',
'        -- if the checkbox is readonly we will still render a hidden field with',
'        -- the value so that it can be used when the page gets submitted',
'        wwv_flow_plugin_util.print_hidden_if_readonly (',
'            p_item_name           => p_item.name,',
'            p_value               => p_value,',
'            p_is_readonly         => p_is_readonly,',
'            p_is_printer_friendly => p_is_printer_friendly );',
'        l_checkbox_postfix := ''_DISPLAY'';',
'',
'        -- Tell APEX that this field is NOT navigable',
'        l_result.is_navigable := false;',
'    else',
'        -- If a page item saves state, we have to call the get_input_name_for_page_item',
'        -- to render the internal hidden p_arg_names field. It will also return the',
'        -- HTML field name which we have to use when we render the HTML input field.',
'        l_name := wwv_flow_plugin.get_input_name_for_page_item(false);',
'',
'        -- render the hidden field which actually stores the checkbox value',
'        sys.htp.prn (',
'            ''<input type="hidden" id="''||p_item.name||''_HIDDEN" name="''||l_name||''" ''||',
'            ''value="''||l_value||''" />'');',
'',
'        -- Add the JavaScript library and the call to initialize the widget',
'        apex_javascript.add_library (',
'            p_name      => ''com_oracle_apex_simple_checkbox.min'',',
'            p_directory => p_plugin.file_prefix,',
'            p_version   => null );',
'',
'        apex_javascript.add_onload_code (',
'            p_code => ''com_oracle_apex_simple_checkbox(''||',
'                      apex_javascript.add_value(p_item.name)||',
'                      ''{''||',
'                      apex_javascript.add_attribute(''unchecked'', l_unchecked_value, false)||',
'                      apex_javascript.add_attribute(''checked'',   l_checked_value, false, false)||',
'                      ''});'' );',
'        ',
'        -- Add the Bootstrap Switch JavasScript library',
'        apex_javascript.add_library (',
'            p_name      => ''bootstrap-switch.min'',',
'            p_directory => p_plugin.file_prefix,',
'            p_version   => null );',
'        -- Add the required css files for Bootstrap Switch',
'        apex_css.add_file(',
'         p_name      => ''bootstrap-switch.min'',',
'         p_directory => p_plugin.file_prefix,',
'         p_version   => null );',
'',
'        -- Tell APEX that this field is navigable',
'        l_result.is_navigable := true;',
'    end if;',
'    -- render the checkbox widget',
'    sys.htp.prn (',
'        ''<input type="checkbox" style="display: none;" id="''||p_item.name||l_checkbox_postfix||''" ''||',
'        ''value="''||l_value||''" ''||',
'        case when l_value = l_checked_value then ''checked="checked" '' end||',
'        case when p_is_readonly or p_is_printer_friendly then ''disabled="disabled" '' end||',
'        coalesce(p_item.element_attributes, ''class="simple_checkbox"'')||'' />'');',
'',
'    -- print label after checkbox',
'    if l_checked_label is not null then',
'        sys.htp.prn(''<label for="''||p_item.name||l_checkbox_postfix||''">''||l_checked_label||''</label>'');',
'    end if;',
'    ',
'    -- If Bootstrap Switch is set to Yes then render it, else render the normal plugin',
'    if l_bootstrap_switch = ''Y'' then',
'        v_html := ''$("#%ID%").bootstrapSwitch();'';',
'        v_html := REPLACE(v_html, ''%ID%'', p_item.name);',
'        apex_javascript.add_onload_code (p_code => v_html);',
'        ',
'            -- Setting the onColour Option',
'        if l_on_colour is not null then',
'            v_html := ''$("#%ID%").bootstrapSwitch("onColor", "%ONCOLOR%");'';',
'            v_html := REPLACE(v_html, ''%ID%'', p_item.name);',
'            v_html := REPLACE(v_html, ''%ONCOLOR%'', l_on_colour);',
'            apex_javascript.add_onload_code (p_code => v_html);',
'        end if;',
'',
'        -- Setting the offColour Option',
'        if l_off_colour is not null then',
'            v_html := ''$("#%ID%").bootstrapSwitch("offColor", "%OFFCOLOR%");'';',
'            v_html := REPLACE(v_html, ''%ID%'', p_item.name);',
'            v_html := REPLACE(v_html, ''%OFFCOLOR%'', l_off_colour);',
'            apex_javascript.add_onload_code (p_code => v_html);',
'        end if;',
'',
'        -- Setting onText Option',
'        if l_on_text is not null then',
'            v_html := ''$("#%ID%").bootstrapSwitch("onText", "%ONTEXT%");'';',
'            v_html := REPLACE(v_html, ''%ID%'', p_item.name);',
'            v_html := REPLACE(v_html, ''%ONTEXT%'', l_on_text);',
'            apex_javascript.add_onload_code (p_code => v_html);',
'        end if;',
'',
'        -- Setting offText Option',
'        if l_off_text is not null then',
'            v_html := ''$("#%ID%").bootstrapSwitch("offText", "%OFFTEXT%");'';',
'            v_html := REPLACE(v_html, ''%ID%'', p_item.name);',
'            v_html := REPLACE(v_html, ''%OFFTEXT%'', l_off_text);',
'            apex_javascript.add_onload_code (p_code => v_html);',
'        end if;',
'',
'        -- Setting Size Option',
'        if l_size is not null then',
'            v_html := ''$("#%ID%").bootstrapSwitch("size", "%SIZE%");'';',
'            v_html := REPLACE(v_html, ''%ID%'', p_item.name);',
'            v_html := REPLACE(v_html, ''%SIZE%'', l_size);',
'            apex_javascript.add_onload_code (p_code => v_html);',
'        end if;',
'        v_html := ''$("#%ID%").on(''''switchChange.bootstrapSwitch'''', function(event, state) {',
'                 apex.event.trigger($(this), ''''switchchange'''');',
'                });'';',
'        v_html := REPLACE(v_html, ''%ID%'', p_item.name);',
'        apex_javascript.add_onload_code (p_code => v_html);',
'    else',
'        v_html := ''$("#%ID%").removeAttr("style");'';',
'        v_html := REPLACE(v_html, ''%ID%'', p_item.name);',
'        apex_javascript.add_onload_code (p_code => v_html);',
'    end if;',
'    return l_result;',
'end render_simple_checkbox;',
'',
'--==============================================================================',
'-- Validates the submitted "Simple Checkbox" value against the configuration to',
'-- make sure that invalid values submitted by hackers are detected.',
'--==============================================================================',
'function validate_simple_checkbox (',
'    p_item   in apex_plugin.t_page_item,',
'    p_plugin in apex_plugin.t_plugin,',
'    p_value  in varchar2 )',
'    return apex_plugin.t_page_item_validation_result',
'is',
'    l_checked_value   varchar2(255) := nvl(p_item.attribute_01, ''Y'');',
'    l_unchecked_value varchar2(255) := p_item.attribute_02;',
'',
'    l_result          apex_plugin.t_page_item_validation_result;',
'begin',
'    if not (   p_value in (l_checked_value, l_unchecked_value)',
'            or (p_value is null and l_unchecked_value is null)',
'           )',
'    then',
'        l_result.message := ''Checkbox contains invalid value!'';',
'    end if;',
'    return l_result;',
'end validate_simple_checkbox;',
''))
,p_render_function=>'render_simple_checkbox'
,p_validation_function=>'validate_simple_checkbox'
,p_standard_attributes=>'VISIBLE:SESSION_STATE:READONLY:SOURCE:ELEMENT:ENCRYPT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'<p>',
'	This item type plug-in displays a single checkbox but allows you to set 2 values (one for checked and another for unchecked). It&#39;s perfect for Y(es)/N(o) type checkboxes.</p>',
'<p>',
'	Without this plug-in, you would need to write a custom computation to get the same functionality.</p>'))
,p_version_identifier=>'1.3'
,p_about_url=>'https://github.com/farzadso/Simple-Checkbox-2--With-Bootstrap-Switch-'
,p_files_version=>4
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(17124877803021440002)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Checked Value'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'Y'
,p_display_length=>10
,p_max_length=>255
,p_is_translatable=>false
,p_help_text=>'Value stored if the checkbox is checked.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(17125429006969643379)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Unchecked Value'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_display_length=>10
,p_max_length=>255
,p_is_translatable=>false
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'<p>Value stored if the checkbox is unchecked. This attribute can also be left blank if you want to store NULL when the checkbox is left unchecked.</p>',
'',
'<p>Note: This value will also be used if the page item is populated with a value which doesn''t match the "Checked Value" or "Unchecked Value".</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(17125428501775641882)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Checkbox Label'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_display_length=>40
,p_is_translatable=>true
,p_help_text=>'Label to be displayed after the checkbox. If you set this optional attribute, you should remove the text in the label attribute of the page item.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(312119007639182004)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Bootstrap Switch'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'This is defaulted to "Yes", select "No" if you want the item to render as a default Simple Checkbox item (no pill functionality).'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(312123872564581585)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'"On" Colour'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(312119007639182004)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312124488311582785)
,p_plugin_attribute_id=>wwv_flow_api.id(312123872564581585)
,p_display_sequence=>10
,p_display_value=>'primary'
,p_return_value=>'primary'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312124844876583630)
,p_plugin_attribute_id=>wwv_flow_api.id(312123872564581585)
,p_display_sequence=>20
,p_display_value=>'info'
,p_return_value=>'info'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312125273894584168)
,p_plugin_attribute_id=>wwv_flow_api.id(312123872564581585)
,p_display_sequence=>30
,p_display_value=>'success'
,p_return_value=>'success'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312125603160585115)
,p_plugin_attribute_id=>wwv_flow_api.id(312123872564581585)
,p_display_sequence=>40
,p_display_value=>'warning'
,p_return_value=>'warning'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312125996699585626)
,p_plugin_attribute_id=>wwv_flow_api.id(312123872564581585)
,p_display_sequence=>50
,p_display_value=>'danger'
,p_return_value=>'danger'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312126450131587143)
,p_plugin_attribute_id=>wwv_flow_api.id(312123872564581585)
,p_display_sequence=>60
,p_display_value=>'default'
,p_return_value=>'default'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(312128756322676507)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'"Off" Colour'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(312119007639182004)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312129387603677326)
,p_plugin_attribute_id=>wwv_flow_api.id(312128756322676507)
,p_display_sequence=>10
,p_display_value=>'primary'
,p_return_value=>'primary'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312129745044677915)
,p_plugin_attribute_id=>wwv_flow_api.id(312128756322676507)
,p_display_sequence=>20
,p_display_value=>'info'
,p_return_value=>'info'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312130189318678525)
,p_plugin_attribute_id=>wwv_flow_api.id(312128756322676507)
,p_display_sequence=>30
,p_display_value=>'success'
,p_return_value=>'success'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312130569677679147)
,p_plugin_attribute_id=>wwv_flow_api.id(312128756322676507)
,p_display_sequence=>40
,p_display_value=>'warning'
,p_return_value=>'warning'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312130906171679923)
,p_plugin_attribute_id=>wwv_flow_api.id(312128756322676507)
,p_display_sequence=>50
,p_display_value=>'danger'
,p_return_value=>'danger'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312131309549680719)
,p_plugin_attribute_id=>wwv_flow_api.id(312128756322676507)
,p_display_sequence=>60
,p_display_value=>'default'
,p_return_value=>'default'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(312132533818720809)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'"On" Text'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(312119007639182004)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(312133146761721644)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'"Off" Text'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(312119007639182004)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(312134982427733216)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Size'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(312119007639182004)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312135583831734058)
,p_plugin_attribute_id=>wwv_flow_api.id(312134982427733216)
,p_display_sequence=>10
,p_display_value=>'Mini'
,p_return_value=>'mini'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312135986106734789)
,p_plugin_attribute_id=>wwv_flow_api.id(312134982427733216)
,p_display_sequence=>20
,p_display_value=>'Small'
,p_return_value=>'small'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312136371595735757)
,p_plugin_attribute_id=>wwv_flow_api.id(312134982427733216)
,p_display_sequence=>30
,p_display_value=>'Normal'
,p_return_value=>'normal'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(312137088054736483)
,p_plugin_attribute_id=>wwv_flow_api.id(312134982427733216)
,p_display_sequence=>40
,p_display_value=>'Large'
,p_return_value=>'large'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(163633788881834036)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_name=>'switchchange'
,p_display_name=>'Switch Changed'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A202A20626F6F7473747261702D737769746368202D207633';
wwv_flow_api.g_varchar2_table(2) := '2E332E320A202A20687474703A2F2F7777772E626F6F7473747261702D7377697463682E6F72670A202A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(3) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A202A20436F7079726967687420323031322D32303133204D6174746961204C6172656E7469730A202A0A202A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(4) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A202A204C6963656E73656420756E6465722074686520417061636865204C6963656E73652C2056657273696F6E20322E30202874686520224C6963656E736522293B';
wwv_flow_api.g_varchar2_table(5) := '0A202A20796F75206D6179206E6F742075736520746869732066696C652065786365707420696E20636F6D706C69616E6365207769746820746865204C6963656E73652E0A202A20596F75206D6179206F627461696E206120636F7079206F6620746865';
wwv_flow_api.g_varchar2_table(6) := '204C6963656E73652061740A202A0A202A2020202020687474703A2F2F7777772E6170616368652E6F72672F6C6963656E7365732F4C4943454E53452D322E300A202A0A202A20556E6C657373207265717569726564206279206170706C696361626C65';
wwv_flow_api.g_varchar2_table(7) := '206C6177206F722061677265656420746F20696E2077726974696E672C20736F6674776172650A202A20646973747269627574656420756E64657220746865204C6963656E7365206973206469737472696275746564206F6E20616E2022415320495322';
wwv_flow_api.g_varchar2_table(8) := '2042415349532C0A202A20574954484F55542057415252414E54494553204F5220434F4E444954494F4E53204F4620414E59204B494E442C206569746865722065787072657373206F7220696D706C6965642E0A202A2053656520746865204C6963656E';
wwv_flow_api.g_varchar2_table(9) := '736520666F7220746865207370656369666963206C616E677561676520676F7665726E696E67207065726D697373696F6E7320616E640A202A206C696D69746174696F6E7320756E64657220746865204C6963656E73652E0A202A203D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(10) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A202A2F0A0A2E626F6F7473747261702D7377697463687B646973706C61793A696E6C69';
wwv_flow_api.g_varchar2_table(11) := '6E652D626C6F636B3B646972656374696F6E3A6C74723B637572736F723A706F696E7465723B626F726465722D7261646975733A3470783B626F726465723A31707820736F6C696420236363633B706F736974696F6E3A72656C61746976653B74657874';
wwv_flow_api.g_varchar2_table(12) := '2D616C69676E3A6C6566743B6F766572666C6F773A68696464656E3B6C696E652D6865696768743A3870783B7A2D696E6465783A303B2D7765626B69742D757365722D73656C6563743A6E6F6E653B2D6D6F7A2D757365722D73656C6563743A6E6F6E65';
wwv_flow_api.g_varchar2_table(13) := '3B2D6D732D757365722D73656C6563743A6E6F6E653B757365722D73656C6563743A6E6F6E653B766572746963616C2D616C69676E3A6D6964646C653B2D7765626B69742D7472616E736974696F6E3A626F726465722D636F6C6F7220656173652D696E';
wwv_flow_api.g_varchar2_table(14) := '2D6F7574202E3135732C626F782D736861646F7720656173652D696E2D6F7574202E3135733B2D6F2D7472616E736974696F6E3A626F726465722D636F6C6F7220656173652D696E2D6F7574202E3135732C626F782D736861646F7720656173652D696E';
wwv_flow_api.g_varchar2_table(15) := '2D6F7574202E3135733B7472616E736974696F6E3A626F726465722D636F6C6F7220656173652D696E2D6F7574202E3135732C626F782D736861646F7720656173652D696E2D6F7574202E3135737D2E626F6F7473747261702D737769746368202E626F';
wwv_flow_api.g_varchar2_table(16) := '6F7473747261702D7377697463682D636F6E7461696E65727B646973706C61793A696E6C696E652D626C6F636B3B746F703A303B626F726465722D7261646975733A3470783B2D7765626B69742D7472616E73666F726D3A7472616E736C617465336428';
wwv_flow_api.g_varchar2_table(17) := '302C302C30293B7472616E73666F726D3A7472616E736C617465336428302C302C30297D2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F66662C2E626F6F7473747261702D737769746368';
wwv_flow_api.g_varchar2_table(18) := '202E626F6F7473747261702D7377697463682D68616E646C652D6F6E2C2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D6C6162656C7B2D7765626B69742D626F782D73697A696E673A626F726465722D626F78';
wwv_flow_api.g_varchar2_table(19) := '3B2D6D6F7A2D626F782D73697A696E673A626F726465722D626F783B626F782D73697A696E673A626F726465722D626F783B637572736F723A706F696E7465723B646973706C61793A696E6C696E652D626C6F636B21696D706F7274616E743B68656967';
wwv_flow_api.g_varchar2_table(20) := '68743A313030253B70616464696E673A36707820313270783B666F6E742D73697A653A313470783B6C696E652D6865696768743A323070787D2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D';
wwv_flow_api.g_varchar2_table(21) := '6F66662C2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F6E7B746578742D616C69676E3A63656E7465723B7A2D696E6465783A317D2E626F6F7473747261702D737769746368202E626F6F';
wwv_flow_api.g_varchar2_table(22) := '7473747261702D7377697463682D68616E646C652D6F66662E626F6F7473747261702D7377697463682D7072696D6172792C2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F6E2E626F6F74';
wwv_flow_api.g_varchar2_table(23) := '73747261702D7377697463682D7072696D6172797B636F6C6F723A236666663B6261636B67726F756E643A233333376162377D2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F66662E626F';
wwv_flow_api.g_varchar2_table(24) := '6F7473747261702D7377697463682D696E666F2C2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F6E2E626F6F7473747261702D7377697463682D696E666F7B636F6C6F723A236666663B62';
wwv_flow_api.g_varchar2_table(25) := '61636B67726F756E643A233562633064657D2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F66662E626F6F7473747261702D7377697463682D737563636573732C2E626F6F747374726170';
wwv_flow_api.g_varchar2_table(26) := '2D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F6E2E626F6F7473747261702D7377697463682D737563636573737B636F6C6F723A236666663B6261636B67726F756E643A233563623835637D2E626F6F7473747261';
wwv_flow_api.g_varchar2_table(27) := '702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F66662E626F6F7473747261702D7377697463682D7761726E696E672C2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68';
wwv_flow_api.g_varchar2_table(28) := '616E646C652D6F6E2E626F6F7473747261702D7377697463682D7761726E696E677B6261636B67726F756E643A236630616434653B636F6C6F723A236666667D2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D';
wwv_flow_api.g_varchar2_table(29) := '68616E646C652D6F66662E626F6F7473747261702D7377697463682D64616E6765722C2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F6E2E626F6F7473747261702D7377697463682D6461';
wwv_flow_api.g_varchar2_table(30) := '6E6765727B636F6C6F723A236666663B6261636B67726F756E643A236439353334667D2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F66662E626F6F7473747261702D7377697463682D64';
wwv_flow_api.g_varchar2_table(31) := '656661756C742C2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F6E2E626F6F7473747261702D7377697463682D64656661756C747B636F6C6F723A233030303B6261636B67726F756E643A';
wwv_flow_api.g_varchar2_table(32) := '236565657D2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D6C6162656C7B746578742D616C69676E3A63656E7465723B6D617267696E2D746F703A2D3170783B6D617267696E2D626F74746F6D3A2D3170783B';
wwv_flow_api.g_varchar2_table(33) := '7A2D696E6465783A3130303B636F6C6F723A233333333B6261636B67726F756E643A236666667D2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F6E7B626F726465722D626F74746F6D2D6C';
wwv_flow_api.g_varchar2_table(34) := '6566742D7261646975733A3370783B626F726465722D746F702D6C6566742D7261646975733A3370787D2E626F6F7473747261702D737769746368202E626F6F7473747261702D7377697463682D68616E646C652D6F66667B626F726465722D626F7474';
wwv_flow_api.g_varchar2_table(35) := '6F6D2D72696768742D7261646975733A3370783B626F726465722D746F702D72696768742D7261646975733A3370787D2E626F6F7473747261702D73776974636820696E7075745B747970653D726164696F5D2C2E626F6F7473747261702D7377697463';
wwv_flow_api.g_varchar2_table(36) := '6820696E7075745B747970653D636865636B626F785D7B706F736974696F6E3A6162736F6C75746521696D706F7274616E743B746F703A303B6C6566743A303B6D617267696E3A303B7A2D696E6465783A2D313B6F7061636974793A303B66696C746572';
wwv_flow_api.g_varchar2_table(37) := '3A616C706861286F7061636974793D30297D2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D6D696E69202E626F6F7473747261702D7377697463682D68616E646C652D6F66662C2E626F6F7473747261702D7377';
wwv_flow_api.g_varchar2_table(38) := '697463682E626F6F7473747261702D7377697463682D6D696E69202E626F6F7473747261702D7377697463682D68616E646C652D6F6E2C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D6D696E69202E626F6F74';
wwv_flow_api.g_varchar2_table(39) := '73747261702D7377697463682D6C6162656C7B70616464696E673A317078203570783B666F6E742D73697A653A313270783B6C696E652D6865696768743A312E357D2E626F6F7473747261702D7377697463682E626F6F7473747261702D737769746368';
wwv_flow_api.g_varchar2_table(40) := '2D736D616C6C202E626F6F7473747261702D7377697463682D68616E646C652D6F66662C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D736D616C6C202E626F6F7473747261702D7377697463682D68616E646C';
wwv_flow_api.g_varchar2_table(41) := '652D6F6E2C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D736D616C6C202E626F6F7473747261702D7377697463682D6C6162656C7B70616464696E673A35707820313070783B666F6E742D73697A653A313270';
wwv_flow_api.g_varchar2_table(42) := '783B6C696E652D6865696768743A312E357D2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D6C61726765202E626F6F7473747261702D7377697463682D68616E646C652D6F66662C2E626F6F7473747261702D73';
wwv_flow_api.g_varchar2_table(43) := '77697463682E626F6F7473747261702D7377697463682D6C61726765202E626F6F7473747261702D7377697463682D68616E646C652D6F6E2C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D6C61726765202E62';
wwv_flow_api.g_varchar2_table(44) := '6F6F7473747261702D7377697463682D6C6162656C7B70616464696E673A36707820313670783B666F6E742D73697A653A313870783B6C696E652D6865696768743A312E333333333333337D2E626F6F7473747261702D7377697463682E626F6F747374';
wwv_flow_api.g_varchar2_table(45) := '7261702D7377697463682D64697361626C65642C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D696E64657465726D696E6174652C2E626F6F7473747261702D7377697463682E626F6F7473747261702D737769';
wwv_flow_api.g_varchar2_table(46) := '7463682D726561646F6E6C797B637572736F723A64656661756C7421696D706F7274616E747D2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D64697361626C6564202E626F6F7473747261702D7377697463682D';
wwv_flow_api.g_varchar2_table(47) := '68616E646C652D6F66662C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D64697361626C6564202E626F6F7473747261702D7377697463682D68616E646C652D6F6E2C2E626F6F7473747261702D737769746368';
wwv_flow_api.g_varchar2_table(48) := '2E626F6F7473747261702D7377697463682D64697361626C6564202E626F6F7473747261702D7377697463682D6C6162656C2C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D696E64657465726D696E61746520';
wwv_flow_api.g_varchar2_table(49) := '2E626F6F7473747261702D7377697463682D68616E646C652D6F66662C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D696E64657465726D696E617465202E626F6F7473747261702D7377697463682D68616E64';
wwv_flow_api.g_varchar2_table(50) := '6C652D6F6E2C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D696E64657465726D696E617465202E626F6F7473747261702D7377697463682D6C6162656C2C2E626F6F7473747261702D7377697463682E626F6F';
wwv_flow_api.g_varchar2_table(51) := '7473747261702D7377697463682D726561646F6E6C79202E626F6F7473747261702D7377697463682D68616E646C652D6F66662C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D726561646F6E6C79202E626F6F';
wwv_flow_api.g_varchar2_table(52) := '7473747261702D7377697463682D68616E646C652D6F6E2C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D726561646F6E6C79202E626F6F7473747261702D7377697463682D6C6162656C7B6F7061636974793A';
wwv_flow_api.g_varchar2_table(53) := '2E353B66696C7465723A616C706861286F7061636974793D3530293B637572736F723A64656661756C7421696D706F7274616E747D2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D616E696D617465202E626F6F';
wwv_flow_api.g_varchar2_table(54) := '7473747261702D7377697463682D636F6E7461696E65727B2D7765626B69742D7472616E736974696F6E3A6D617267696E2D6C656674202E35733B2D6F2D7472616E736974696F6E3A6D617267696E2D6C656674202E35733B7472616E736974696F6E3A';
wwv_flow_api.g_varchar2_table(55) := '6D617267696E2D6C656674202E35737D2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D696E7665727365202E626F6F7473747261702D7377697463682D68616E646C652D6F6E7B626F726465722D726164697573';
wwv_flow_api.g_varchar2_table(56) := '3A30203370782033707820307D2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D696E7665727365202E626F6F7473747261702D7377697463682D68616E646C652D6F66667B626F726465722D7261646975733A33';
wwv_flow_api.g_varchar2_table(57) := '707820302030203370787D2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D666F63757365647B626F726465722D636F6C6F723A233636616665393B6F75746C696E653A303B2D7765626B69742D626F782D736861';
wwv_flow_api.g_varchar2_table(58) := '646F773A696E73657420302031707820317078207267626128302C302C302C2E303735292C302030203870782072676261283130322C3137352C3233332C2E36293B626F782D736861646F773A696E73657420302031707820317078207267626128302C';
wwv_flow_api.g_varchar2_table(59) := '302C302C2E303735292C302030203870782072676261283130322C3137352C3233332C2E36297D2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D696E76657273652E626F6F7473747261702D7377697463682D6F';
wwv_flow_api.g_varchar2_table(60) := '6666202E626F6F7473747261702D7377697463682D6C6162656C2C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D6F6E202E626F6F7473747261702D7377697463682D6C6162656C7B626F726465722D626F7474';
wwv_flow_api.g_varchar2_table(61) := '6F6D2D72696768742D7261646975733A3370783B626F726465722D746F702D72696768742D7261646975733A3370787D2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D696E76657273652E626F6F747374726170';
wwv_flow_api.g_varchar2_table(62) := '2D7377697463682D6F6E202E626F6F7473747261702D7377697463682D6C6162656C2C2E626F6F7473747261702D7377697463682E626F6F7473747261702D7377697463682D6F6666202E626F6F7473747261702D7377697463682D6C6162656C7B626F';
wwv_flow_api.g_varchar2_table(63) := '726465722D626F74746F6D2D6C6566742D7261646975733A3370783B626F726465722D746F702D6C6566742D7261646975733A3370787D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(312116936255143987)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_file_name=>'bootstrap-switch.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A202A20626F6F7473747261702D737769746368202D207633';
wwv_flow_api.g_varchar2_table(2) := '2E332E320A202A20687474703A2F2F7777772E626F6F7473747261702D7377697463682E6F72670A202A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(3) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A202A20436F7079726967687420323031322D32303133204D6174746961204C6172656E7469730A202A0A202A203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(4) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A202A204C6963656E73656420756E6465722074686520417061636865204C6963656E73652C2056657273696F6E20322E30202874686520224C6963656E736522293B';
wwv_flow_api.g_varchar2_table(5) := '0A202A20796F75206D6179206E6F742075736520746869732066696C652065786365707420696E20636F6D706C69616E6365207769746820746865204C6963656E73652E0A202A20596F75206D6179206F627461696E206120636F7079206F6620746865';
wwv_flow_api.g_varchar2_table(6) := '204C6963656E73652061740A202A0A202A2020202020687474703A2F2F7777772E6170616368652E6F72672F6C6963656E7365732F4C4943454E53452D322E300A202A0A202A20556E6C657373207265717569726564206279206170706C696361626C65';
wwv_flow_api.g_varchar2_table(7) := '206C6177206F722061677265656420746F20696E2077726974696E672C20736F6674776172650A202A20646973747269627574656420756E64657220746865204C6963656E7365206973206469737472696275746564206F6E20616E2022415320495322';
wwv_flow_api.g_varchar2_table(8) := '2042415349532C0A202A20574954484F55542057415252414E54494553204F5220434F4E444954494F4E53204F4620414E59204B494E442C206569746865722065787072657373206F7220696D706C6965642E0A202A2053656520746865204C6963656E';
wwv_flow_api.g_varchar2_table(9) := '736520666F7220746865207370656369666963206C616E677561676520676F7665726E696E67207065726D697373696F6E7320616E640A202A206C696D69746174696F6E7320756E64657220746865204C6963656E73652E0A202A203D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(10) := '3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A202A2F0A0A2866756E6374696F6E28297B76617220743D5B5D2E736C6963653B216675';
wwv_flow_api.g_varchar2_table(11) := '6E6374696F6E28652C69297B2275736520737472696374223B766172206E3B72657475726E206E3D66756E6374696F6E28297B66756E6374696F6E207428742C69297B6E756C6C3D3D69262628693D7B7D292C746869732E24656C656D656E743D652874';
wwv_flow_api.g_varchar2_table(12) := '292C746869732E6F7074696F6E733D652E657874656E64287B7D2C652E666E2E626F6F7473747261705377697463682E64656661756C74732C7B73746174653A746869732E24656C656D656E742E697328223A636865636B656422292C73697A653A7468';
wwv_flow_api.g_varchar2_table(13) := '69732E24656C656D656E742E64617461282273697A6522292C616E696D6174653A746869732E24656C656D656E742E646174612822616E696D61746522292C64697361626C65643A746869732E24656C656D656E742E697328223A64697361626C656422';
wwv_flow_api.g_varchar2_table(14) := '292C726561646F6E6C793A746869732E24656C656D656E742E697328225B726561646F6E6C795D22292C696E64657465726D696E6174653A746869732E24656C656D656E742E646174612822696E64657465726D696E61746522292C696E76657273653A';
wwv_flow_api.g_varchar2_table(15) := '746869732E24656C656D656E742E646174612822696E766572736522292C726164696F416C6C4F66663A746869732E24656C656D656E742E646174612822726164696F2D616C6C2D6F666622292C6F6E436F6C6F723A746869732E24656C656D656E742E';
wwv_flow_api.g_varchar2_table(16) := '6461746128226F6E2D636F6C6F7222292C6F6666436F6C6F723A746869732E24656C656D656E742E6461746128226F66662D636F6C6F7222292C6F6E546578743A746869732E24656C656D656E742E6461746128226F6E2D7465787422292C6F66665465';
wwv_flow_api.g_varchar2_table(17) := '78743A746869732E24656C656D656E742E6461746128226F66662D7465787422292C6C6162656C546578743A746869732E24656C656D656E742E6461746128226C6162656C2D7465787422292C68616E646C6557696474683A746869732E24656C656D65';
wwv_flow_api.g_varchar2_table(18) := '6E742E64617461282268616E646C652D776964746822292C6C6162656C57696474683A746869732E24656C656D656E742E6461746128226C6162656C2D776964746822292C62617365436C6173733A746869732E24656C656D656E742E64617461282262';
wwv_flow_api.g_varchar2_table(19) := '6173652D636C61737322292C77726170706572436C6173733A746869732E24656C656D656E742E646174612822777261707065722D636C61737322297D2C69292C746869732E707265764F7074696F6E733D7B7D2C746869732E24777261707065723D65';
wwv_flow_api.g_varchar2_table(20) := '28223C6469763E222C7B22636C617373223A66756E6374696F6E2874297B72657475726E2066756E6374696F6E28297B76617220653B72657475726E20653D5B22222B742E6F7074696F6E732E62617365436C6173735D2E636F6E63617428742E5F6765';
wwv_flow_api.g_varchar2_table(21) := '74436C617373657328742E6F7074696F6E732E77726170706572436C61737329292C652E7075736828742E6F7074696F6E732E73746174653F742E6F7074696F6E732E62617365436C6173732B222D6F6E223A742E6F7074696F6E732E62617365436C61';
wwv_flow_api.g_varchar2_table(22) := '73732B222D6F666622292C6E756C6C213D742E6F7074696F6E732E73697A652626652E7075736828742E6F7074696F6E732E62617365436C6173732B222D222B742E6F7074696F6E732E73697A65292C742E6F7074696F6E732E64697361626C65642626';
wwv_flow_api.g_varchar2_table(23) := '652E7075736828742E6F7074696F6E732E62617365436C6173732B222D64697361626C656422292C742E6F7074696F6E732E726561646F6E6C792626652E7075736828742E6F7074696F6E732E62617365436C6173732B222D726561646F6E6C7922292C';
wwv_flow_api.g_varchar2_table(24) := '742E6F7074696F6E732E696E64657465726D696E6174652626652E7075736828742E6F7074696F6E732E62617365436C6173732B222D696E64657465726D696E61746522292C742E6F7074696F6E732E696E76657273652626652E7075736828742E6F70';
wwv_flow_api.g_varchar2_table(25) := '74696F6E732E62617365436C6173732B222D696E766572736522292C742E24656C656D656E742E617474722822696422292626652E7075736828742E6F7074696F6E732E62617365436C6173732B222D69642D222B742E24656C656D656E742E61747472';
wwv_flow_api.g_varchar2_table(26) := '282269642229292C652E6A6F696E28222022297D7D28746869732928297D292C746869732E24636F6E7461696E65723D6528223C6469763E222C7B22636C617373223A746869732E6F7074696F6E732E62617365436C6173732B222D636F6E7461696E65';
wwv_flow_api.g_varchar2_table(27) := '72227D292C746869732E246F6E3D6528223C7370616E3E222C7B68746D6C3A746869732E6F7074696F6E732E6F6E546578742C22636C617373223A746869732E6F7074696F6E732E62617365436C6173732B222D68616E646C652D6F6E20222B74686973';
wwv_flow_api.g_varchar2_table(28) := '2E6F7074696F6E732E62617365436C6173732B222D222B746869732E6F7074696F6E732E6F6E436F6C6F727D292C746869732E246F66663D6528223C7370616E3E222C7B68746D6C3A746869732E6F7074696F6E732E6F6666546578742C22636C617373';
wwv_flow_api.g_varchar2_table(29) := '223A746869732E6F7074696F6E732E62617365436C6173732B222D68616E646C652D6F666620222B746869732E6F7074696F6E732E62617365436C6173732B222D222B746869732E6F7074696F6E732E6F6666436F6C6F727D292C746869732E246C6162';
wwv_flow_api.g_varchar2_table(30) := '656C3D6528223C7370616E3E222C7B68746D6C3A746869732E6F7074696F6E732E6C6162656C546578742C22636C617373223A746869732E6F7074696F6E732E62617365436C6173732B222D6C6162656C227D292C746869732E24656C656D656E742E6F';
wwv_flow_api.g_varchar2_table(31) := '6E2822696E69742E626F6F747374726170537769746368222C66756E6374696F6E2865297B72657475726E2066756E6374696F6E28297B72657475726E20652E6F7074696F6E732E6F6E496E69742E6170706C7928742C617267756D656E7473297D7D28';
wwv_flow_api.g_varchar2_table(32) := '7468697329292C746869732E24656C656D656E742E6F6E28227377697463684368616E67652E626F6F747374726170537769746368222C66756E6374696F6E2869297B72657475726E2066756E6374696F6E286E297B72657475726E21313D3D3D692E6F';
wwv_flow_api.g_varchar2_table(33) := '7074696F6E732E6F6E5377697463684368616E67652E6170706C7928742C617267756D656E7473293F692E24656C656D656E742E697328223A726164696F22293F6528225B6E616D653D27222B692E24656C656D656E742E6174747228226E616D652229';
wwv_flow_api.g_varchar2_table(34) := '2B22275D22292E74726967676572282270726576696F757353746174652E626F6F747374726170537769746368222C2130293A692E24656C656D656E742E74726967676572282270726576696F757353746174652E626F6F747374726170537769746368';
wwv_flow_api.g_varchar2_table(35) := '222C2130293A766F696420307D7D287468697329292C746869732E24636F6E7461696E65723D746869732E24656C656D656E742E7772617028746869732E24636F6E7461696E6572292E706172656E7428292C746869732E24777261707065723D746869';
wwv_flow_api.g_varchar2_table(36) := '732E24636F6E7461696E65722E7772617028746869732E2477726170706572292E706172656E7428292C746869732E24656C656D656E742E6265666F726528746869732E6F7074696F6E732E696E76657273653F746869732E246F66663A746869732E24';
wwv_flow_api.g_varchar2_table(37) := '6F6E292E6265666F726528746869732E246C6162656C292E6265666F726528746869732E6F7074696F6E732E696E76657273653F746869732E246F6E3A746869732E246F6666292C746869732E6F7074696F6E732E696E64657465726D696E6174652626';
wwv_flow_api.g_varchar2_table(38) := '746869732E24656C656D656E742E70726F702822696E64657465726D696E617465222C2130292C746869732E5F696E697428292C746869732E5F656C656D656E7448616E646C65727328292C746869732E5F68616E646C6548616E646C65727328292C74';
wwv_flow_api.g_varchar2_table(39) := '6869732E5F6C6162656C48616E646C65727328292C746869732E5F666F726D48616E646C657228292C746869732E5F65787465726E616C4C6162656C48616E646C657228292C746869732E24656C656D656E742E747269676765722822696E69742E626F';
wwv_flow_api.g_varchar2_table(40) := '6F747374726170537769746368222C746869732E6F7074696F6E732E7374617465297D72657475726E20742E70726F746F747970652E5F636F6E7374727563746F723D742C742E70726F746F747970652E736574507265764F7074696F6E733D66756E63';
wwv_flow_api.g_varchar2_table(41) := '74696F6E28297B72657475726E20746869732E707265764F7074696F6E733D652E657874656E642821302C7B7D2C746869732E6F7074696F6E73297D2C742E70726F746F747970652E73746174653D66756E6374696F6E28742C69297B72657475726E22';
wwv_flow_api.g_varchar2_table(42) := '756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E73746174653A746869732E6F7074696F6E732E64697361626C65647C7C746869732E6F7074696F6E732E726561646F6E6C793F746869732E24656C656D656E743A74';
wwv_flow_api.g_varchar2_table(43) := '6869732E6F7074696F6E732E7374617465262621746869732E6F7074696F6E732E726164696F416C6C4F66662626746869732E24656C656D656E742E697328223A726164696F22293F746869732E24656C656D656E743A28746869732E24656C656D656E';
wwv_flow_api.g_varchar2_table(44) := '742E697328223A726164696F22293F6528225B6E616D653D27222B746869732E24656C656D656E742E6174747228226E616D6522292B22275D22292E74726967676572282273657450726576696F75734F7074696F6E732E626F6F747374726170537769';
wwv_flow_api.g_varchar2_table(45) := '74636822293A746869732E24656C656D656E742E74726967676572282273657450726576696F75734F7074696F6E732E626F6F74737472617053776974636822292C746869732E6F7074696F6E732E696E64657465726D696E6174652626746869732E69';
wwv_flow_api.g_varchar2_table(46) := '6E64657465726D696E617465282131292C743D2121742C746869732E24656C656D656E742E70726F702822636865636B6564222C74292E7472696767657228226368616E67652E626F6F747374726170537769746368222C69292C746869732E24656C65';
wwv_flow_api.g_varchar2_table(47) := '6D656E74297D2C742E70726F746F747970652E746F67676C6553746174653D66756E6374696F6E2874297B72657475726E20746869732E6F7074696F6E732E64697361626C65647C7C746869732E6F7074696F6E732E726561646F6E6C793F746869732E';
wwv_flow_api.g_varchar2_table(48) := '24656C656D656E743A746869732E6F7074696F6E732E696E64657465726D696E6174653F28746869732E696E64657465726D696E617465282131292C746869732E737461746528213029293A746869732E24656C656D656E742E70726F70282263686563';
wwv_flow_api.g_varchar2_table(49) := '6B6564222C21746869732E6F7074696F6E732E7374617465292E7472696767657228226368616E67652E626F6F747374726170537769746368222C74297D2C742E70726F746F747970652E73697A653D66756E6374696F6E2874297B72657475726E2275';
wwv_flow_api.g_varchar2_table(50) := '6E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E73697A653A286E756C6C213D746869732E6F7074696F6E732E73697A652626746869732E24777261707065722E72656D6F7665436C61737328746869732E6F7074696F';
wwv_flow_api.g_varchar2_table(51) := '6E732E62617365436C6173732B222D222B746869732E6F7074696F6E732E73697A65292C742626746869732E24777261707065722E616464436C61737328746869732E6F7074696F6E732E62617365436C6173732B222D222B74292C746869732E5F7769';
wwv_flow_api.g_varchar2_table(52) := '64746828292C746869732E5F636F6E7461696E6572506F736974696F6E28292C746869732E6F7074696F6E732E73697A653D742C746869732E24656C656D656E74297D2C742E70726F746F747970652E616E696D6174653D66756E6374696F6E2874297B';
wwv_flow_api.g_varchar2_table(53) := '72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E616E696D6174653A28743D2121742C743D3D3D746869732E6F7074696F6E732E616E696D6174653F746869732E24656C656D656E743A746869732E';
wwv_flow_api.g_varchar2_table(54) := '746F67676C65416E696D6174652829297D2C742E70726F746F747970652E746F67676C65416E696D6174653D66756E6374696F6E28297B72657475726E20746869732E6F7074696F6E732E616E696D6174653D21746869732E6F7074696F6E732E616E69';
wwv_flow_api.g_varchar2_table(55) := '6D6174652C746869732E24777261707065722E746F67676C65436C61737328746869732E6F7074696F6E732E62617365436C6173732B222D616E696D61746522292C746869732E24656C656D656E747D2C742E70726F746F747970652E64697361626C65';
wwv_flow_api.g_varchar2_table(56) := '643D66756E6374696F6E2874297B72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E64697361626C65643A28743D2121742C743D3D3D746869732E6F7074696F6E732E64697361626C65643F746869';
wwv_flow_api.g_varchar2_table(57) := '732E24656C656D656E743A746869732E746F67676C6544697361626C65642829297D2C742E70726F746F747970652E746F67676C6544697361626C65643D66756E6374696F6E28297B72657475726E20746869732E6F7074696F6E732E64697361626C65';
wwv_flow_api.g_varchar2_table(58) := '643D21746869732E6F7074696F6E732E64697361626C65642C746869732E24656C656D656E742E70726F70282264697361626C6564222C746869732E6F7074696F6E732E64697361626C6564292C746869732E24777261707065722E746F67676C65436C';
wwv_flow_api.g_varchar2_table(59) := '61737328746869732E6F7074696F6E732E62617365436C6173732B222D64697361626C656422292C746869732E24656C656D656E747D2C742E70726F746F747970652E726561646F6E6C793D66756E6374696F6E2874297B72657475726E22756E646566';
wwv_flow_api.g_varchar2_table(60) := '696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E726561646F6E6C793A28743D2121742C743D3D3D746869732E6F7074696F6E732E726561646F6E6C793F746869732E24656C656D656E743A746869732E746F67676C6552656164';
wwv_flow_api.g_varchar2_table(61) := '6F6E6C792829297D2C742E70726F746F747970652E746F67676C65526561646F6E6C793D66756E6374696F6E28297B72657475726E20746869732E6F7074696F6E732E726561646F6E6C793D21746869732E6F7074696F6E732E726561646F6E6C792C74';
wwv_flow_api.g_varchar2_table(62) := '6869732E24656C656D656E742E70726F702822726561646F6E6C79222C746869732E6F7074696F6E732E726561646F6E6C79292C746869732E24777261707065722E746F67676C65436C61737328746869732E6F7074696F6E732E62617365436C617373';
wwv_flow_api.g_varchar2_table(63) := '2B222D726561646F6E6C7922292C746869732E24656C656D656E747D2C742E70726F746F747970652E696E64657465726D696E6174653D66756E6374696F6E2874297B72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E';
wwv_flow_api.g_varchar2_table(64) := '6F7074696F6E732E696E64657465726D696E6174653A28743D2121742C743D3D3D746869732E6F7074696F6E732E696E64657465726D696E6174653F746869732E24656C656D656E743A746869732E746F67676C65496E64657465726D696E6174652829';
wwv_flow_api.g_varchar2_table(65) := '297D2C742E70726F746F747970652E746F67676C65496E64657465726D696E6174653D66756E6374696F6E28297B72657475726E20746869732E6F7074696F6E732E696E64657465726D696E6174653D21746869732E6F7074696F6E732E696E64657465';
wwv_flow_api.g_varchar2_table(66) := '726D696E6174652C746869732E24656C656D656E742E70726F702822696E64657465726D696E617465222C746869732E6F7074696F6E732E696E64657465726D696E617465292C746869732E24777261707065722E746F67676C65436C61737328746869';
wwv_flow_api.g_varchar2_table(67) := '732E6F7074696F6E732E62617365436C6173732B222D696E64657465726D696E61746522292C746869732E5F636F6E7461696E6572506F736974696F6E28292C746869732E24656C656D656E747D2C742E70726F746F747970652E696E76657273653D66';
wwv_flow_api.g_varchar2_table(68) := '756E6374696F6E2874297B72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E696E76657273653A28743D2121742C743D3D3D746869732E6F7074696F6E732E696E76657273653F746869732E24656C';
wwv_flow_api.g_varchar2_table(69) := '656D656E743A746869732E746F67676C65496E76657273652829297D2C742E70726F746F747970652E746F67676C65496E76657273653D66756E6374696F6E28297B76617220742C653B72657475726E20746869732E24777261707065722E746F67676C';
wwv_flow_api.g_varchar2_table(70) := '65436C61737328746869732E6F7074696F6E732E62617365436C6173732B222D696E766572736522292C653D746869732E246F6E2E636C6F6E65282130292C743D746869732E246F66662E636C6F6E65282130292C746869732E246F6E2E7265706C6163';
wwv_flow_api.g_varchar2_table(71) := '65576974682874292C746869732E246F66662E7265706C616365576974682865292C746869732E246F6E3D742C746869732E246F66663D652C746869732E6F7074696F6E732E696E76657273653D21746869732E6F7074696F6E732E696E76657273652C';
wwv_flow_api.g_varchar2_table(72) := '746869732E24656C656D656E747D2C742E70726F746F747970652E6F6E436F6C6F723D66756E6374696F6E2874297B76617220653B72657475726E20653D746869732E6F7074696F6E732E6F6E436F6C6F722C22756E646566696E6564223D3D74797065';
wwv_flow_api.g_varchar2_table(73) := '6F6620743F653A286E756C6C213D652626746869732E246F6E2E72656D6F7665436C61737328746869732E6F7074696F6E732E62617365436C6173732B222D222B65292C746869732E246F6E2E616464436C61737328746869732E6F7074696F6E732E62';
wwv_flow_api.g_varchar2_table(74) := '617365436C6173732B222D222B74292C746869732E6F7074696F6E732E6F6E436F6C6F723D742C746869732E24656C656D656E74297D2C742E70726F746F747970652E6F6666436F6C6F723D66756E6374696F6E2874297B76617220653B72657475726E';
wwv_flow_api.g_varchar2_table(75) := '20653D746869732E6F7074696F6E732E6F6666436F6C6F722C22756E646566696E6564223D3D747970656F6620743F653A286E756C6C213D652626746869732E246F66662E72656D6F7665436C61737328746869732E6F7074696F6E732E62617365436C';
wwv_flow_api.g_varchar2_table(76) := '6173732B222D222B65292C746869732E246F66662E616464436C61737328746869732E6F7074696F6E732E62617365436C6173732B222D222B74292C746869732E6F7074696F6E732E6F6666436F6C6F723D742C746869732E24656C656D656E74297D2C';
wwv_flow_api.g_varchar2_table(77) := '742E70726F746F747970652E6F6E546578743D66756E6374696F6E2874297B72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E6F6E546578743A28746869732E246F6E2E68746D6C2874292C746869';
wwv_flow_api.g_varchar2_table(78) := '732E5F776964746828292C746869732E5F636F6E7461696E6572506F736974696F6E28292C746869732E6F7074696F6E732E6F6E546578743D742C746869732E24656C656D656E74297D2C742E70726F746F747970652E6F6666546578743D66756E6374';
wwv_flow_api.g_varchar2_table(79) := '696F6E2874297B72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E6F6666546578743A28746869732E246F66662E68746D6C2874292C746869732E5F776964746828292C746869732E5F636F6E7461';
wwv_flow_api.g_varchar2_table(80) := '696E6572506F736974696F6E28292C746869732E6F7074696F6E732E6F6666546578743D742C746869732E24656C656D656E74297D2C742E70726F746F747970652E6C6162656C546578743D66756E6374696F6E2874297B72657475726E22756E646566';
wwv_flow_api.g_varchar2_table(81) := '696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E6C6162656C546578743A28746869732E246C6162656C2E68746D6C2874292C746869732E5F776964746828292C746869732E6F7074696F6E732E6C6162656C546578743D742C74';
wwv_flow_api.g_varchar2_table(82) := '6869732E24656C656D656E74297D2C742E70726F746F747970652E68616E646C6557696474683D66756E6374696F6E2874297B72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E68616E646C655769';
wwv_flow_api.g_varchar2_table(83) := '6474683A28746869732E6F7074696F6E732E68616E646C6557696474683D742C746869732E5F776964746828292C746869732E5F636F6E7461696E6572506F736974696F6E28292C746869732E24656C656D656E74297D2C742E70726F746F747970652E';
wwv_flow_api.g_varchar2_table(84) := '6C6162656C57696474683D66756E6374696F6E2874297B72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E6C6162656C57696474683A28746869732E6F7074696F6E732E6C6162656C57696474683D';
wwv_flow_api.g_varchar2_table(85) := '742C746869732E5F776964746828292C746869732E5F636F6E7461696E6572506F736974696F6E28292C746869732E24656C656D656E74297D2C742E70726F746F747970652E62617365436C6173733D66756E6374696F6E2874297B72657475726E2074';
wwv_flow_api.g_varchar2_table(86) := '6869732E6F7074696F6E732E62617365436C6173737D2C742E70726F746F747970652E77726170706572436C6173733D66756E6374696F6E2874297B72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E73';
wwv_flow_api.g_varchar2_table(87) := '2E77726170706572436C6173733A28747C7C28743D652E666E2E626F6F7473747261705377697463682E64656661756C74732E77726170706572436C617373292C746869732E24777261707065722E72656D6F7665436C61737328746869732E5F676574';
wwv_flow_api.g_varchar2_table(88) := '436C617373657328746869732E6F7074696F6E732E77726170706572436C617373292E6A6F696E2822202229292C746869732E24777261707065722E616464436C61737328746869732E5F676574436C61737365732874292E6A6F696E2822202229292C';
wwv_flow_api.g_varchar2_table(89) := '746869732E6F7074696F6E732E77726170706572436C6173733D742C746869732E24656C656D656E74297D2C742E70726F746F747970652E726164696F416C6C4F66663D66756E6374696F6E2874297B72657475726E22756E646566696E6564223D3D74';
wwv_flow_api.g_varchar2_table(90) := '7970656F6620743F746869732E6F7074696F6E732E726164696F416C6C4F66663A28743D2121742C743D3D3D746869732E6F7074696F6E732E726164696F416C6C4F66663F746869732E24656C656D656E743A28746869732E6F7074696F6E732E726164';
wwv_flow_api.g_varchar2_table(91) := '696F416C6C4F66663D742C746869732E24656C656D656E7429297D2C742E70726F746F747970652E6F6E496E69743D66756E6374696F6E2874297B72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(92) := '6F6E496E69743A28747C7C28743D652E666E2E626F6F7473747261705377697463682E64656661756C74732E6F6E496E6974292C746869732E6F7074696F6E732E6F6E496E69743D742C746869732E24656C656D656E74297D2C742E70726F746F747970';
wwv_flow_api.g_varchar2_table(93) := '652E6F6E5377697463684368616E67653D66756E6374696F6E2874297B72657475726E22756E646566696E6564223D3D747970656F6620743F746869732E6F7074696F6E732E6F6E5377697463684368616E67653A28747C7C28743D652E666E2E626F6F';
wwv_flow_api.g_varchar2_table(94) := '7473747261705377697463682E64656661756C74732E6F6E5377697463684368616E6765292C746869732E6F7074696F6E732E6F6E5377697463684368616E67653D742C746869732E24656C656D656E74297D2C742E70726F746F747970652E64657374';
wwv_flow_api.g_varchar2_table(95) := '726F793D66756E6374696F6E28297B76617220743B72657475726E20743D746869732E24656C656D656E742E636C6F736573742822666F726D22292C742E6C656E6774682626742E6F6666282272657365742E626F6F7473747261705377697463682229';
wwv_flow_api.g_varchar2_table(96) := '2E72656D6F7665446174612822626F6F7473747261702D73776974636822292C746869732E24636F6E7461696E65722E6368696C6472656E28292E6E6F7428746869732E24656C656D656E74292E72656D6F766528292C746869732E24656C656D656E74';
wwv_flow_api.g_varchar2_table(97) := '2E756E7772617028292E756E7772617028292E6F666628222E626F6F74737472617053776974636822292E72656D6F7665446174612822626F6F7473747261702D73776974636822292C746869732E24656C656D656E747D2C742E70726F746F74797065';
wwv_flow_api.g_varchar2_table(98) := '2E5F77696474683D66756E6374696F6E28297B76617220742C653B72657475726E20743D746869732E246F6E2E61646428746869732E246F6666292C742E61646428746869732E246C6162656C292E63737328227769647468222C2222292C653D226175';
wwv_flow_api.g_varchar2_table(99) := '746F223D3D3D746869732E6F7074696F6E732E68616E646C6557696474683F4D6174682E6D617828746869732E246F6E2E776964746828292C746869732E246F66662E77696474682829293A746869732E6F7074696F6E732E68616E646C655769647468';
wwv_flow_api.g_varchar2_table(100) := '2C742E77696474682865292C746869732E246C6162656C2E77696474682866756E6374696F6E2874297B72657475726E2066756E6374696F6E28692C6E297B72657475726E226175746F22213D3D742E6F7074696F6E732E6C6162656C57696474683F74';
wwv_flow_api.g_varchar2_table(101) := '2E6F7074696F6E732E6C6162656C57696474683A653E6E3F653A6E7D7D287468697329292C746869732E5F68616E646C6557696474683D746869732E246F6E2E6F75746572576964746828292C746869732E5F6C6162656C57696474683D746869732E24';
wwv_flow_api.g_varchar2_table(102) := '6C6162656C2E6F75746572576964746828292C746869732E24636F6E7461696E65722E776964746828322A746869732E5F68616E646C6557696474682B746869732E5F6C6162656C5769647468292C746869732E24777261707065722E77696474682874';
wwv_flow_api.g_varchar2_table(103) := '6869732E5F68616E646C6557696474682B746869732E5F6C6162656C5769647468297D2C742E70726F746F747970652E5F636F6E7461696E6572506F736974696F6E3D66756E6374696F6E28742C65297B72657475726E206E756C6C3D3D74262628743D';
wwv_flow_api.g_varchar2_table(104) := '746869732E6F7074696F6E732E7374617465292C746869732E24636F6E7461696E65722E63737328226D617267696E2D6C656674222C66756E6374696F6E2865297B72657475726E2066756E6374696F6E28297B76617220693B72657475726E20693D5B';
wwv_flow_api.g_varchar2_table(105) := '302C222D222B652E5F68616E646C6557696474682B227078225D2C652E6F7074696F6E732E696E64657465726D696E6174653F222D222B652E5F68616E646C6557696474682F322B227078223A743F652E6F7074696F6E732E696E76657273653F695B31';
wwv_flow_api.g_varchar2_table(106) := '5D3A695B305D3A652E6F7074696F6E732E696E76657273653F695B305D3A695B315D7D7D287468697329292C653F73657454696D656F75742866756E6374696F6E28297B72657475726E206528297D2C3530293A766F696420307D2C742E70726F746F74';
wwv_flow_api.g_varchar2_table(107) := '7970652E5F696E69743D66756E6374696F6E28297B76617220742C653B72657475726E20743D66756E6374696F6E2874297B72657475726E2066756E6374696F6E28297B72657475726E20742E736574507265764F7074696F6E7328292C742E5F776964';
wwv_flow_api.g_varchar2_table(108) := '746828292C742E5F636F6E7461696E6572506F736974696F6E286E756C6C2C66756E6374696F6E28297B72657475726E20742E6F7074696F6E732E616E696D6174653F742E24777261707065722E616464436C61737328742E6F7074696F6E732E626173';
wwv_flow_api.g_varchar2_table(109) := '65436C6173732B222D616E696D61746522293A766F696420307D297D7D2874686973292C746869732E24777261707065722E697328223A76697369626C6522293F7428293A653D692E736574496E74657276616C2866756E6374696F6E286E297B726574';
wwv_flow_api.g_varchar2_table(110) := '75726E2066756E6374696F6E28297B72657475726E206E2E24777261707065722E697328223A76697369626C6522293F287428292C692E636C656172496E74657276616C286529293A766F696420307D7D2874686973292C3530297D2C742E70726F746F';
wwv_flow_api.g_varchar2_table(111) := '747970652E5F656C656D656E7448616E646C6572733D66756E6374696F6E28297B72657475726E20746869732E24656C656D656E742E6F6E287B2273657450726576696F75734F7074696F6E732E626F6F747374726170537769746368223A66756E6374';
wwv_flow_api.g_varchar2_table(112) := '696F6E2874297B72657475726E2066756E6374696F6E2865297B72657475726E20742E736574507265764F7074696F6E7328297D7D2874686973292C2270726576696F757353746174652E626F6F747374726170537769746368223A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(113) := '2874297B72657475726E2066756E6374696F6E2865297B72657475726E20742E6F7074696F6E733D742E707265764F7074696F6E732C742E6F7074696F6E732E696E64657465726D696E6174652626742E24777261707065722E616464436C6173732874';
wwv_flow_api.g_varchar2_table(114) := '2E6F7074696F6E732E62617365436C6173732B222D696E64657465726D696E61746522292C742E24656C656D656E742E70726F702822636865636B6564222C742E6F7074696F6E732E7374617465292E7472696767657228226368616E67652E626F6F74';
wwv_flow_api.g_varchar2_table(115) := '7374726170537769746368222C2130297D7D2874686973292C226368616E67652E626F6F747374726170537769746368223A66756E6374696F6E2874297B72657475726E2066756E6374696F6E28692C6E297B766172206F3B72657475726E20692E7072';
wwv_flow_api.g_varchar2_table(116) := '6576656E7444656661756C7428292C692E73746F70496D6D65646961746550726F7061676174696F6E28292C6F3D742E24656C656D656E742E697328223A636865636B656422292C742E5F636F6E7461696E6572506F736974696F6E286F292C6F213D3D';
wwv_flow_api.g_varchar2_table(117) := '742E6F7074696F6E732E73746174653F28742E6F7074696F6E732E73746174653D6F2C742E24777261707065722E746F67676C65436C61737328742E6F7074696F6E732E62617365436C6173732B222D6F666622292E746F67676C65436C61737328742E';
wwv_flow_api.g_varchar2_table(118) := '6F7074696F6E732E62617365436C6173732B222D6F6E22292C6E3F766F696420303A28742E24656C656D656E742E697328223A726164696F222926266528225B6E616D653D27222B742E24656C656D656E742E6174747228226E616D6522292B22275D22';
wwv_flow_api.g_varchar2_table(119) := '292E6E6F7428742E24656C656D656E74292E70726F702822636865636B6564222C2131292E7472696767657228226368616E67652E626F6F747374726170537769746368222C2130292C742E24656C656D656E742E747269676765722822737769746368';
wwv_flow_api.g_varchar2_table(120) := '4368616E67652E626F6F747374726170537769746368222C5B6F5D2929293A766F696420307D7D2874686973292C22666F6375732E626F6F747374726170537769746368223A66756E6374696F6E2874297B72657475726E2066756E6374696F6E286529';
wwv_flow_api.g_varchar2_table(121) := '7B72657475726E20652E70726576656E7444656661756C7428292C742E24777261707065722E616464436C61737328742E6F7074696F6E732E62617365436C6173732B222D666F637573656422297D7D2874686973292C22626C75722E626F6F74737472';
wwv_flow_api.g_varchar2_table(122) := '6170537769746368223A66756E6374696F6E2874297B72657475726E2066756E6374696F6E2865297B72657475726E20652E70726576656E7444656661756C7428292C742E24777261707065722E72656D6F7665436C61737328742E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(123) := '62617365436C6173732B222D666F637573656422297D7D2874686973292C226B6579646F776E2E626F6F747374726170537769746368223A66756E6374696F6E2874297B72657475726E2066756E6374696F6E2865297B696628652E7768696368262621';
wwv_flow_api.g_varchar2_table(124) := '742E6F7074696F6E732E64697361626C6564262621742E6F7074696F6E732E726561646F6E6C792973776974636828652E7768696368297B636173652033373A72657475726E20652E70726576656E7444656661756C7428292C652E73746F70496D6D65';
wwv_flow_api.g_varchar2_table(125) := '646961746550726F7061676174696F6E28292C742E7374617465282131293B636173652033393A72657475726E20652E70726576656E7444656661756C7428292C652E73746F70496D6D65646961746550726F7061676174696F6E28292C742E73746174';
wwv_flow_api.g_varchar2_table(126) := '65282130297D7D7D2874686973297D297D2C742E70726F746F747970652E5F68616E646C6548616E646C6572733D66756E6374696F6E28297B72657475726E20746869732E246F6E2E6F6E2822636C69636B2E626F6F747374726170537769746368222C';
wwv_flow_api.g_varchar2_table(127) := '66756E6374696F6E2874297B72657475726E2066756E6374696F6E2865297B72657475726E20652E70726576656E7444656661756C7428292C652E73746F7050726F7061676174696F6E28292C742E7374617465282131292C742E24656C656D656E742E';
wwv_flow_api.g_varchar2_table(128) := '747269676765722822666F6375732E626F6F74737472617053776974636822297D7D287468697329292C746869732E246F66662E6F6E2822636C69636B2E626F6F747374726170537769746368222C66756E6374696F6E2874297B72657475726E206675';
wwv_flow_api.g_varchar2_table(129) := '6E6374696F6E2865297B72657475726E20652E70726576656E7444656661756C7428292C652E73746F7050726F7061676174696F6E28292C742E7374617465282130292C742E24656C656D656E742E747269676765722822666F6375732E626F6F747374';
wwv_flow_api.g_varchar2_table(130) := '72617053776974636822297D7D287468697329297D2C742E70726F746F747970652E5F6C6162656C48616E646C6572733D66756E6374696F6E28297B72657475726E20746869732E246C6162656C2E6F6E287B636C69636B3A66756E6374696F6E287429';
wwv_flow_api.g_varchar2_table(131) := '7B72657475726E20742E73746F7050726F7061676174696F6E28297D2C226D6F757365646F776E2E626F6F74737472617053776974636820746F75636873746172742E626F6F747374726170537769746368223A66756E6374696F6E2874297B72657475';
wwv_flow_api.g_varchar2_table(132) := '726E2066756E6374696F6E2865297B72657475726E20742E5F6472616753746172747C7C742E6F7074696F6E732E64697361626C65647C7C742E6F7074696F6E732E726561646F6E6C793F766F696420303A28652E70726576656E7444656661756C7428';
wwv_flow_api.g_varchar2_table(133) := '292C652E73746F7050726F7061676174696F6E28292C742E5F6472616753746172743D28652E70616765587C7C652E6F726967696E616C4576656E742E746F75636865735B305D2E7061676558292D7061727365496E7428742E24636F6E7461696E6572';
wwv_flow_api.g_varchar2_table(134) := '2E63737328226D617267696E2D6C65667422292C3130292C742E6F7074696F6E732E616E696D6174652626742E24777261707065722E72656D6F7665436C61737328742E6F7074696F6E732E62617365436C6173732B222D616E696D61746522292C742E';
wwv_flow_api.g_varchar2_table(135) := '24656C656D656E742E747269676765722822666F6375732E626F6F7473747261705377697463682229297D7D2874686973292C226D6F7573656D6F76652E626F6F74737472617053776974636820746F7563686D6F76652E626F6F747374726170537769';
wwv_flow_api.g_varchar2_table(136) := '746368223A66756E6374696F6E2874297B72657475726E2066756E6374696F6E2865297B76617220693B6966286E756C6C213D742E5F647261675374617274262628652E70726576656E7444656661756C7428292C693D28652E70616765587C7C652E6F';
wwv_flow_api.g_varchar2_table(137) := '726967696E616C4576656E742E746F75636865735B305D2E7061676558292D742E5F6472616753746172742C2128693C2D742E5F68616E646C6557696474687C7C693E3029292972657475726E20742E5F64726167456E643D692C742E24636F6E746169';
wwv_flow_api.g_varchar2_table(138) := '6E65722E63737328226D617267696E2D6C656674222C742E5F64726167456E642B22707822297D7D2874686973292C226D6F75736575702E626F6F74737472617053776974636820746F756368656E642E626F6F747374726170537769746368223A6675';
wwv_flow_api.g_varchar2_table(139) := '6E6374696F6E2874297B72657475726E2066756E6374696F6E2865297B76617220693B696628742E5F6472616753746172742972657475726E20652E70726576656E7444656661756C7428292C742E6F7074696F6E732E616E696D6174652626742E2477';
wwv_flow_api.g_varchar2_table(140) := '7261707065722E616464436C61737328742E6F7074696F6E732E62617365436C6173732B222D616E696D61746522292C742E5F64726167456E643F28693D742E5F64726167456E643E2D28742E5F68616E646C6557696474682F32292C742E5F64726167';
wwv_flow_api.g_varchar2_table(141) := '456E643D21312C742E737461746528742E6F7074696F6E732E696E76657273653F21693A6929293A742E73746174652821742E6F7074696F6E732E7374617465292C742E5F6472616753746172743D21317D7D2874686973292C226D6F7573656C656176';
wwv_flow_api.g_varchar2_table(142) := '652E626F6F747374726170537769746368223A66756E6374696F6E2874297B72657475726E2066756E6374696F6E2865297B72657475726E20742E246C6162656C2E7472696767657228226D6F75736575702E626F6F7473747261705377697463682229';
wwv_flow_api.g_varchar2_table(143) := '7D7D2874686973297D297D2C742E70726F746F747970652E5F65787465726E616C4C6162656C48616E646C65723D66756E6374696F6E28297B76617220743B72657475726E20743D746869732E24656C656D656E742E636C6F7365737428226C6162656C';
wwv_flow_api.g_varchar2_table(144) := '22292C742E6F6E2822636C69636B222C66756E6374696F6E2865297B72657475726E2066756E6374696F6E2869297B72657475726E20692E70726576656E7444656661756C7428292C692E73746F70496D6D65646961746550726F7061676174696F6E28';
wwv_flow_api.g_varchar2_table(145) := '292C692E7461726765743D3D3D745B305D3F652E746F67676C65537461746528293A766F696420307D7D287468697329297D2C742E70726F746F747970652E5F666F726D48616E646C65723D66756E6374696F6E28297B76617220743B72657475726E20';
wwv_flow_api.g_varchar2_table(146) := '743D746869732E24656C656D656E742E636C6F736573742822666F726D22292C742E646174612822626F6F7473747261702D73776974636822293F766F696420303A742E6F6E282272657365742E626F6F747374726170537769746368222C66756E6374';
wwv_flow_api.g_varchar2_table(147) := '696F6E28297B72657475726E20692E73657454696D656F75742866756E6374696F6E28297B72657475726E20742E66696E642822696E70757422292E66696C7465722866756E6374696F6E28297B72657475726E20652874686973292E64617461282262';
wwv_flow_api.g_varchar2_table(148) := '6F6F7473747261702D73776974636822297D292E656163682866756E6374696F6E28297B72657475726E20652874686973292E626F6F74737472617053776974636828227374617465222C746869732E636865636B6564297D297D2C31297D292E646174';
wwv_flow_api.g_varchar2_table(149) := '612822626F6F7473747261702D737769746368222C2130297D2C742E70726F746F747970652E5F676574436C61737365733D66756E6374696F6E2874297B76617220692C6E2C6F2C733B69662821652E697341727261792874292972657475726E5B7468';
wwv_flow_api.g_varchar2_table(150) := '69732E6F7074696F6E732E62617365436C6173732B222D222B745D3B666F72286E3D5B5D2C6F3D302C733D742E6C656E6774683B733E6F3B6F2B2B29693D745B6F5D2C6E2E7075736828746869732E6F7074696F6E732E62617365436C6173732B222D22';
wwv_flow_api.g_varchar2_table(151) := '2B69293B72657475726E206E7D2C747D28292C652E666E2E626F6F7473747261705377697463683D66756E6374696F6E28297B76617220692C6F2C733B72657475726E206F3D617267756D656E74735B305D2C693D323C3D617267756D656E74732E6C65';
wwv_flow_api.g_varchar2_table(152) := '6E6774683F742E63616C6C28617267756D656E74732C31293A5B5D2C733D746869732C746869732E656163682866756E6374696F6E28297B76617220742C613B72657475726E20743D652874686973292C613D742E646174612822626F6F747374726170';
wwv_flow_api.g_varchar2_table(153) := '2D73776974636822292C617C7C742E646174612822626F6F7473747261702D737769746368222C613D6E6577206E28746869732C6F29292C22737472696E67223D3D747970656F66206F3F733D615B6F5D2E6170706C7928612C69293A766F696420307D';
wwv_flow_api.g_varchar2_table(154) := '292C737D2C652E666E2E626F6F7473747261705377697463682E436F6E7374727563746F723D6E2C652E666E2E626F6F7473747261705377697463682E64656661756C74733D7B73746174653A21302C73697A653A6E756C6C2C616E696D6174653A2130';
wwv_flow_api.g_varchar2_table(155) := '2C64697361626C65643A21312C726561646F6E6C793A21312C696E64657465726D696E6174653A21312C696E76657273653A21312C726164696F416C6C4F66663A21312C6F6E436F6C6F723A227072696D617279222C6F6666436F6C6F723A2264656661';
wwv_flow_api.g_varchar2_table(156) := '756C74222C6F6E546578743A224F4E222C6F6666546578743A224F4646222C6C6162656C546578743A22266E6273703B222C68616E646C6557696474683A226175746F222C6C6162656C57696474683A226175746F222C62617365436C6173733A22626F';
wwv_flow_api.g_varchar2_table(157) := '6F7473747261702D737769746368222C77726170706572436C6173733A2277726170706572222C6F6E496E69743A66756E6374696F6E28297B7D2C6F6E5377697463684368616E67653A66756E6374696F6E28297B7D7D7D2877696E646F772E6A517565';
wwv_flow_api.g_varchar2_table(158) := '72792C77696E646F77297D292E63616C6C2874686973293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(312117353322144686)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_file_name=>'bootstrap-switch.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E20636F6D5F6F7261636C655F617065785F73696D706C655F636865636B626F7828652C63297B76617220623D617065782E6A5175657279282223222B65292C613D617065782E6A5175657279282223222B652B225F48494444454E22';
wwv_flow_api.g_varchar2_table(2) := '293B66756E6374696F6E206428297B612E76616C2828622E697328223A636865636B656422293D3D3D74727565293F632E636865636B65643A632E756E636865636B6564297D617065782E6A5175657279282223222B65292E6F6E282773776974636863';
wwv_flow_api.g_varchar2_table(3) := '68616E6765272C2064293B617065782E6A517565727928646F63756D656E74292E62696E642822617065786265666F7265706167657375626D6974222C64293B617065782E7769646765742E696E6974506167654974656D28652C7B73657456616C7565';
wwv_flow_api.g_varchar2_table(4) := '3A66756E6374696F6E2866297B622E617474722822636865636B6564222C28663D3D3D632E636865636B656429293B6428297D2C67657456616C75653A66756E6374696F6E28297B72657475726E20612E76616C28297D7D297D3B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(15339441405621604422)
,p_plugin_id=>wwv_flow_api.id(17124832905782365193)
,p_file_name=>'com_oracle_apex_simple_checkbox.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
