package com.totaltel.web.portal.page.agent;

import com.totaltel.web.portal.page.BaseUserPage;
import com.totaltel.web.portal.service.exception.EVDSServiceException;
import com.totaltel.web.portal.service.model.BeneficiaryCollection;
import com.totaltel.web.portal.service.model.Subscriber;
import com.totaltel.web.wicket.component.validator.NumericValidator;
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
 * Time: 10:51 AM
 * To change this template use File | Settings | File Templates.
 */
@MountPath(value = "agent/money/validate")
@ShiroSecurityConstraint(constraint = ShiroConstraint.HasPermission, value = "CWSPORT:R", unauthorizedMessage = "You are not authorized to view this page")
public class AgentMoneyCollection extends BaseUserPage {
    private static final long serialVersionUID = -1129886617229545708L;

    final Logger logger = LoggerFactory.getLogger(AgentMoneyCollection.class);

    public AgentMoneyCollection() {

        final Form<BeneficiaryCollection> form = new Form<BeneficiaryCollection>("form",
                new CompoundPropertyModel<BeneficiaryCollection>(
                        new LoadableDetachableModel<BeneficiaryCollection>() {

                            private static final long serialVersionUID = 1571250997123676488L;

                            @Override
                            protected BeneficiaryCollection load() {
                                return new BeneficiaryCollection();
                            }
                        })) {


            private static final long serialVersionUID = -356057876017329002L;

            protected void onSubmit() {
                logger.debug(this.getModelObject().toString());
                
                try {
                    BeneficiaryCollection model = this.getModelObject();
                    
                    if(model.getSenderMsisdn()==null || model.getSenderMsisdn().isEmpty()) {
                        Subscriber subscriber = serviceManager.getISubscriberService().getSubscriberByBeneficiaryMsisdn(model.getBeneficiaryMsisdn());
                        model.setSenderMsisdn(subscriber.getDeviceIdentification());
                    }

                    model.setTerminalId(_agent.getTerminalId());
                    model = serviceManager.getIAgentService().dokuValidateBeneficiaryCollection(model);
                    setResponsePage(new AgentMoneyCollectionConfirmation(model));
                } catch(EVDSServiceException e) {
                    error(e.getErrorCode() + " " + e.getMessage());
                }
                
            }
        };

        form.add(new FeedbackPanel("feedback"));
        form.add(new TextField("transSerialNo").setRequired(true).add(new NumericValidator()));
        form.add(new TextField("beneficiaryMsisdn").setRequired(true).add(new NumericValidator()));
        form.add(new ButtonExtended("submit", new Model<String>("label.agent.beneficiary.collection.beneficiary.confirm")));
        add(form);
    }
}
