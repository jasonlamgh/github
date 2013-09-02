package com.totaltel.web.wicket.component.validator;

import java.util.regex.Pattern;

/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 19/10/12
 * Time: 11:21 AM
 * To change this template use File | Settings | File Templates.
 */
public class AlphaNumericValidator extends DefaultIValidator {

    private static final long serialVersionUID = -9204780873801244782L;

    private final String REGULAR_EXPRESSION = "[a-zA-Z0-9]+";

    public AlphaNumericValidator() {
        pattern = Pattern.compile(REGULAR_EXPRESSION);
    }
}
