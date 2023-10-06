/**
 * Allows auto-conversion of Leads based on criteria.
 * For example, this class can be invoked by Flow, Process Builder, or even Apex Trigger.
 *
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_convertLead.htm
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableVariable.htm
 *
 * Developed by Doug Ayers, douglascayers.com https://github.com/douglascayers/sfdc-auto-convert-leads-process
 */

/*
 BSD 3-Clause License

Copyright (c) 2017, Doug Ayers
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
public with sharing class ConvertLeadsInvocable {
  /**
   * Represents the required and optional configuration parameters to a single lead convert request.
   * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_convertLead.htm
   */
  public class LeadConvertRequest {
    @InvocableVariable(
      label='Lead ID'
      description='ID of the Lead to convert'
      required=true
    )
    public ID leadId;

    @InvocableVariable(
      label='Converted Status'
      description='Lead Status picklist value that indicates this Lead is converted'
      required=true
    )
    public String convertedStatus;

    @InvocableVariable(
      label='Account ID'
      description='The specific Account to convert Lead into. If blank then creates new Account.'
    )
    public ID accountId;

    @InvocableVariable(
      label='Contact ID'
      description='The specific Contact to convert Lead into. If blank then creates new Contact.'
    )
    public ID contactId;

    @InvocableVariable(
      label='Overwrite Lead Source?'
      description='Overwrite the LeadSource field on the target Contact with the LeadSource field from the Lead? Default is false. If true then must also specify "Contact ID".'
    )
    public Boolean overwriteLeadSource = false;

    @InvocableVariable(
      label='Opportunity ID'
      description='The specific Opportunity to convert Lead into. If blank then creates new Contact if createOpportunity is true.'
    )
    public ID opportunityId;

    @InvocableVariable(
      label='Create Opportunity?'
      description='Create an Opportunity? Default is true.'
    )
    public Boolean createOpportunity = true;

    @InvocableVariable(
      label='Opportunity Name'
      description='If "Create Opportunity" is true then this is the name of the new opportunity. If blank then defaults to Company field from the Lead.'
    )
    public String opportunityName;

    @InvocableVariable(
      label='Owner ID'
      description='Specific user to own the new Account, Contact, and Opportunity records created. Default is the Lead owner.'
    )
    public ID ownerId;

    @InvocableVariable(
      label='Send Email to Owner?'
      description='Send an email notification to owner specified in "Owner ID"? Default is false.'
    )
    public Boolean sendEmailToOwner = false;
  }

  /**
   * Represents the successful results of a single lead convert.
   * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_database_leadconvertresult.htm
   */
  public class LeadConvertResult {
    @InvocableVariable(label='Lead ID')
    public ID leadId;

    @InvocableVariable(label='Account ID')
    public ID accountId;

    @InvocableVariable(label='Contact ID')
    public ID contactId;

    @InvocableVariable(label='Opportunity ID')
    public ID opportunityId;
  }

  // --------------------------------------------------------------------------------

  @InvocableMethod(label='Convert Leads')
  public static List<LeadConvertResult> convertLeads(
    List<LeadConvertRequest> requests
  ) {
    try {
      // transform the invocable request to database convert request
      List<Database.LeadConvert> convertRequests = new List<Database.LeadConvert>();
      for (LeadConvertRequest request : requests) {
        convertRequests.add(transform(request));
      }

      // convert leads, all or none
      // if any has error then exception is thrown automatically and changes rolled back
      List<Database.LeadConvertResult> convertResults = doConvert(
        convertRequests,
        true
      );

      // transform the database convert results to invocable result
      List<LeadConvertResult> results = new List<LeadConvertResult>();
      for (Database.LeadConvertResult convertResult : convertResults) {
        results.add(transform(convertResult));
      }

      System.debug(JSON.serialize(requests.get(requests.size())));

      return results;
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
  }

  private static List<Database.LeadConvertResult> doConvert(
    List<Database.LeadConvert> convertRequests,
    Boolean allOrNone
  ) {
    System.debug(getLimits());
    // convert the leads
    System.debug('Converting leads : ' + convertRequests.size());
    return Database.convertLead(convertRequests, allOrNone);
  }

  private static String getLimits() {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      Url.getSalesforceBaseUrl().toExternalForm() +
      '/services/data/v58.0/limits/'
    );
    request.setMethod('GET');
    request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

    HttpResponse response = http.send(request);
    return response.getBody();
  }

  // --------------------------------------------------------------------------------

  private static Database.LeadConvert transform(LeadConvertRequest request) {
    Database.LeadConvert convertRequest = new Database.LeadConvert();

    convertRequest.setLeadId(request.leadId);
    convertRequest.setConvertedStatus(request.convertedStatus);

    if (request.accountId != null) {
      convertRequest.setAccountId(request.accountId);
    }

    if (request.contactId != null) {
      convertRequest.setContactId(request.contactId);
    }

    if (request.overwriteLeadSource != null && request.overwriteLeadSource) {
      convertRequest.setOverwriteLeadSource(request.overwriteLeadSource);
    }

    if (request.opportunityId != null) {
      convertRequest.setOpportunityId(request.opportunityId);
    } else {
      if (request.createOpportunity != null && !request.createOpportunity) {
        convertRequest.setDoNotCreateOpportunity(!request.createOpportunity);
      }

      if (request.opportunityName != null) {
        convertRequest.setOpportunityName(request.opportunityName);
      }
    }

    if (request.ownerId != null) {
      convertRequest.setOwnerId(request.ownerId);
    }

    if (request.sendEmailToOwner != null && request.sendEmailToOwner) {
      convertRequest.setSendNotificationEmail(request.sendEmailToOwner);
    }

    return convertRequest;
  }

  private static LeadConvertResult transform(
    Database.LeadConvertResult convertResult
  ) {
    LeadConvertResult result = new LeadConvertResult();

    result.leadId = convertResult.getLeadId();
    result.accountId = convertResult.getAccountId();
    result.contactId = convertResult.getContactId();
    result.opportunityId = convertResult.getOpportunityId();

    return result;
  }

  public class ConvertLeadException extends Exception {
  }
}
