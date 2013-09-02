package com.totaltel.web.portal.page.agent;

import com.totaltel.web.portal.WebApplication;
import com.totaltel.web.portal.page.BaseUserPage;
import com.totaltel.web.portal.service.exception.EVDSServiceException;
import com.totaltel.web.portal.service.model.BeneficiaryCollection;
import com.totaltel.web.wicket.markup.html.form.ButtonExtended;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.CompoundPropertyModel;
import org.apache.wicket.model.LoadableDetachableModel;
import org.apache.wicket.model.Model;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wicketstuff.annotation.mount.MountPath;
import org.wicketstuff.shiro.ShiroConstraint;
import org.wicketstuff.shiro.annotation.ShiroSecurityConstraint;

/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 9/11/12
 * Time: 10:55 AM
 * To change this template use File | Settings | File Templates.
 */
@MountPath(value = "agent/money/confirm")
@ShiroSecurityConstraint(constraint = ShiroConstraint.HasPermission, value = "CWSPORT:R", unauthorizedMessage = "You are not authorized to view this page")
public class AgentMoneyCollectionConfirmation extends BaseUserPage {

    private static final long serialVersionUID = 2523974221464776368L;

    final Logger logger = LoggerFactory.getLogger(AgentMoneyCollectionConfirmation.class);

    public AgentMoneyCollectionConfirmation(final BeneficiaryCollection beneficiaryCollection) {
        final Form<BeneficiaryCollection> form = new Form<BeneficiaryCollection>("form",
                new CompoundPropertyModel<BeneficiaryCollection>(
                        new LoadableDetachableModel<BeneficiaryCollection>() {

                            private static final long serialVersionUID = -2752131151151812799L;

                            @Override
                            protected BeneficiaryCollection load() {
                                return new BeneficiaryCollection();
                            }
                        })) {

            private static final long serialVersionUID = 6195263426702225852L;

            protected void onSubmit() {
                logger.debug(this.getModelObject().toString());

                try {
                    BeneficiaryCollection model = this.getModelObject();

                    BeneficiaryCollection obj = new BeneficiaryCollection();
                    obj.setSenderMsisdn(beneficiaryCollection.getSenderMsisdn());
                    obj.setTerminalId(beneficiaryCollection.getTerminalId());
                    obj.setAgentPin(beneficiaryCollection.getAgentPin());
                    obj.setBeneficiaryMsisdn(beneficiaryCollection.getBeneficiaryMsisdn());
                    obj.setTransSerialNo(beneficiaryCollection.getTransSerialNo());
                    obj.setBeneficiaryPin(model.getBeneficiaryPin());

                    obj = serviceManager.getIAgentService().dokuValidateBeneficiaryCollection(obj);
                    obj = serviceManager.getIAgentService().dokuBeneficiaryCollection(obj);

                    StringBuffer sb = new StringBuffer();
                    sb.append(WebApplication.getStringResource("label.agent.beneficiary.collection.success")).append(" ");
                    sb.append(obj.getFirstName()).append(" ");
                    sb.append(obj.getLastName()).append(" ");
                    sb.append(obj.getContactNo()).append(" ");
                    sb.append(WebApplication.getStringResource("label.agent.beneficiary.collection.success.value")).append(" ");
                    sb.append(obj.getCollectionValue());

                    success(sb.toString());
                } catch(EVDSServiceException e) {
                    error(e.getErrorCode() + " " + e.getMessage());
                }
            }
        };

        form.add(new FeedbackPanel("feedback"));
        form.add(new TextField("beneficiaryPin").setRequired(true));
        form.add(new ButtonExtended("submit", new Model<String>("label.agent.beneficiary.collection.beneficiary.confirm")));
        add(form);
    }


}
